"""Authenticated streaming encryption for Cyber Drive personal-drive files.

Logical filenames remain stable, but the *contents* on disk are a versioned
header followed by authenticated AES-256-GCM chunks. The 32-byte storage key is
created at first launch with owner-only permissions and must be backed up
separately from the encrypted files. Never put it in source archives.
"""
from __future__ import annotations

import os
import secrets
import struct
import tempfile
from pathlib import Path
from typing import BinaryIO, Iterator

from .crypto import encrypt_stream, iter_decrypt_stream as _iter_crypto_decrypt_stream, new_object_id

PERSONAL_MAGIC = b"CDUSER1\x00"  # 8 bytes
KEY_BYTES = 32
OBJECT_ID_BYTES = 64
COPY_CHUNK_SIZE = 1024 * 1024


def load_or_create_key(key_path: str | os.PathLike[str]) -> bytes:
    path = Path(key_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    except FileExistsError:
        pass
    else:
        with os.fdopen(fd, "wb") as stream:
            stream.write(os.urandom(KEY_BYTES))
            stream.flush()
            os.fsync(stream.fileno())
    key = path.read_bytes()
    if len(key) != KEY_BYTES:
        raise RuntimeError(f"Personal-drive encryption key at {path} must be exactly 32 bytes.")
    try:
        os.chmod(path, 0o600)
    except OSError:
        pass
    return key


def _aad_object_id(object_id: str, plaintext_size: int) -> str:
    # Bind clear header metadata to each GCM chunk. Header edits fail closed.
    return f"{object_id}:{plaintext_size}"


def encrypted_header(stream: BinaryIO) -> tuple[int, str] | None:
    """Read the personal-file header at the current position; restore position."""
    try:
        position = stream.tell()
    except (OSError, AttributeError):
        return None
    try:
        if stream.read(len(PERSONAL_MAGIC)) != PERSONAL_MAGIC:
            return None
        size_raw = stream.read(8)
        object_raw = stream.read(OBJECT_ID_BYTES)
        if len(size_raw) != 8 or len(object_raw) != OBJECT_ID_BYTES:
            raise ValueError("Truncated personal-drive encrypted header")
        size = struct.unpack(">Q", size_raw)[0]
        object_id = object_raw.decode("ascii")
        if len(object_id) != OBJECT_ID_BYTES or any(c not in "0123456789abcdef" for c in object_id):
            raise ValueError("Invalid personal-drive object identifier")
        return size, object_id
    finally:
        stream.seek(position)


def is_encrypted_file(path: str | os.PathLike[str]) -> bool:
    try:
        with open(path, "rb") as stream:
            return stream.read(len(PERSONAL_MAGIC)) == PERSONAL_MAGIC
    except OSError:
        return False


def plaintext_size(path: str | os.PathLike[str]) -> int:
    with open(path, "rb") as stream:
        header = encrypted_header(stream)
        if header is not None:
            return header[0]
    return os.path.getsize(path)


def encrypt_stream_to_file(source: BinaryIO, destination: str | os.PathLike[str],
                           key: bytes, plaintext_size_bytes: int) -> int:
    """Encrypt directly to a temporary file then atomically publish it.

    A hard-link commit prevents overwriting an existing destination when two
    uploads race to choose the same logical filename.
    """
    if len(key) != KEY_BYTES:
        raise ValueError("Personal storage key must be 32 bytes")
    if plaintext_size_bytes < 0:
        raise ValueError("Invalid plaintext size")
    target = Path(destination)
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary_name = tempfile.mkstemp(prefix=".cd-encrypt-", dir=str(target.parent))
    try:
        with os.fdopen(fd, "wb") as encrypted:
            object_id = new_object_id()
            encrypted.write(PERSONAL_MAGIC)
            encrypted.write(struct.pack(">Q", plaintext_size_bytes))
            encrypted.write(object_id.encode("ascii"))
            actual = encrypt_stream(source, encrypted, key,
                                    _aad_object_id(object_id, plaintext_size_bytes))
            encrypted.flush()
            os.fsync(encrypted.fileno())
            if actual != plaintext_size_bytes:
                raise ValueError("Upload size changed while encrypting")
        os.chmod(temporary_name, 0o600)
        os.link(temporary_name, target)  # fails rather than clobber an existing target
        os.unlink(temporary_name)
        return actual
    except Exception:
        try:
            os.unlink(temporary_name)
        except OSError:
            pass
        raise


def iter_decrypt_stream(source: BinaryIO, key: bytes) -> Iterator[bytes]:
    """Yield authenticated plaintext chunks; consume to EOF to verify finality."""
    start = source.tell()
    head = source.read(len(PERSONAL_MAGIC))
    if head != PERSONAL_MAGIC:
        source.seek(start)
        while True:
            chunk = source.read(COPY_CHUNK_SIZE)
            if not chunk:
                break
            yield chunk
        return
    size_raw = source.read(8)
    object_raw = source.read(OBJECT_ID_BYTES)
    if len(size_raw) != 8 or len(object_raw) != OBJECT_ID_BYTES:
        raise ValueError("Truncated personal-drive encrypted header")
    expected_size = struct.unpack(">Q", size_raw)[0]
    object_id = object_raw.decode("ascii")
    if len(object_id) != OBJECT_ID_BYTES or any(c not in "0123456789abcdef" for c in object_id):
        raise ValueError("Invalid personal-drive object identifier")
    count = 0
    for chunk in _iter_crypto_decrypt_stream(source, key, _aad_object_id(object_id, expected_size)):
        count += len(chunk)
        if count > expected_size:
            raise ValueError("Encrypted object exceeds authenticated size")
        yield chunk
    if count != expected_size:
        raise ValueError("Encrypted object size does not match authenticated header")


def decrypt_file_to_path(source_path: str | os.PathLike[str], destination_path: str | os.PathLike[str], key: bytes) -> None:
    target = Path(destination_path)
    with open(source_path, "rb") as source, open(target, "xb") as destination:
        for chunk in iter_decrypt_stream(source, key):
            destination.write(chunk)
        destination.flush()
        os.fsync(destination.fileno())


def read_file_limited(path: str | os.PathLike[str], key: bytes, limit: int) -> bytes:
    """Read at most limit+1 plaintext bytes for bounded previews."""
    result = bytearray()
    with open(path, "rb") as source:
        for chunk in iter_decrypt_stream(source, key):
            remaining = limit + 1 - len(result)
            if remaining <= 0:
                break
            result.extend(chunk[:remaining])
            if len(result) > limit:
                break
    return bytes(result)


def migrate_plaintext_file(path: str | os.PathLike[str], key: bytes) -> bool:
    """Atomically replace a legacy plaintext file with an encrypted copy."""
    target = Path(path)
    if target.is_symlink() or not target.is_file() or is_encrypted_file(target):
        return False
    size = target.stat().st_size
    fd, temporary_name = tempfile.mkstemp(prefix=".cd-migrate-", dir=str(target.parent))
    try:
        object_id = new_object_id()
        with os.fdopen(fd, "wb") as encrypted, open(target, "rb") as source:
            encrypted.write(PERSONAL_MAGIC)
            encrypted.write(struct.pack(">Q", size))
            encrypted.write(object_id.encode("ascii"))
            actual = encrypt_stream(source, encrypted, key, _aad_object_id(object_id, size))
            encrypted.flush()
            os.fsync(encrypted.fileno())
        if actual != size:
            raise ValueError("File size changed during encryption migration")
        os.chmod(temporary_name, 0o600)
        os.replace(temporary_name, target)
        try:
            os.chmod(target, 0o600)
        except OSError:
            pass
        return True
    except Exception:
        try:
            os.unlink(temporary_name)
        except OSError:
            pass
        raise


def iter_decrypt_range(source: BinaryIO, key: bytes, start: int, end: int) -> Iterator[bytes]:
    """Decrypt only authenticated chunks intersecting inclusive plaintext byte range.

    Full chunks have fixed-width records, enabling indexed reads for browser media
    seeking without writing a plaintext temporary file or decrypting from byte zero.
    """
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    from .crypto import MAGIC as STREAM_MAGIC, NONCE_BYTES, TAG_BYTES, _aad

    header = encrypted_header(source)
    if header is None:
        source.seek(start)
        remaining = end - start + 1
        while remaining > 0:
            block = source.read(min(COPY_CHUNK_SIZE, remaining))
            if not block:
                break
            remaining -= len(block)
            yield block
        return
    size, object_id = header
    if start < 0 or end < start or end >= size:
        raise ValueError("Invalid plaintext byte range")
    source.seek(len(PERSONAL_MAGIC) + 8 + OBJECT_ID_BYTES)
    if source.read(len(STREAM_MAGIC)) != STREAM_MAGIC:
        raise ValueError("Invalid encrypted stream header")
    raw_chunk_size = source.read(4)
    if len(raw_chunk_size) != 4:
        raise ValueError("Truncated encrypted stream header")
    chunk_size = struct.unpack(">I", raw_chunk_size)[0]
    if chunk_size < 1 or chunk_size > 8 * 1024 * 1024:
        raise ValueError("Invalid encrypted chunk size")

    import math
    last_index = max(0, math.ceil(size / chunk_size) - 1)
    first_index = start // chunk_size
    final_index = end // chunk_size
    header_bytes = len(PERSONAL_MAGIC) + 8 + OBJECT_ID_BYTES + len(STREAM_MAGIC) + 4
    stride = 4 + NONCE_BYTES + chunk_size + TAG_BYTES + 1
    aes = AESGCM(key)
    aad_id = _aad_object_id(object_id, size)
    for index in range(first_index, final_index + 1):
        expected_size = min(chunk_size, size - index * chunk_size)
        record_offset = header_bytes + index * stride
        source.seek(record_offset)
        raw_len = source.read(4)
        if len(raw_len) != 4 or struct.unpack(">I", raw_len)[0] != expected_size:
            raise ValueError("Corrupt encrypted chunk index")
        nonce = source.read(NONCE_BYTES)
        ciphertext = source.read(expected_size + TAG_BYTES)
        marker = source.read(1)
        if len(nonce) != NONCE_BYTES or len(ciphertext) != expected_size + TAG_BYTES:
            raise ValueError("Truncated encrypted chunk")
        expected_final = index == last_index
        if marker != (b"\x01" if expected_final else b"\x00"):
            raise ValueError("Invalid encrypted chunk finality marker")
        plaintext = aes.decrypt(nonce, ciphertext, _aad(aad_id, index, expected_final))
        if len(plaintext) != expected_size:
            raise ValueError("Encrypted chunk size mismatch")
        chunk_start = index * chunk_size
        slice_start = max(0, start - chunk_start)
        slice_end = min(expected_size, end - chunk_start + 1)
        if slice_end > slice_start:
            yield plaintext[slice_start:slice_end]
