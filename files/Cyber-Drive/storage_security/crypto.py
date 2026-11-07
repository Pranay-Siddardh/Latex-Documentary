"""Chunked authenticated encryption for Cyber Drive object storage.

This module provides authenticated chunk encryption for encrypted room-transfer objects and the personal-storage adapter. Keep logical path handling separate from cryptographic object identifiers.
Format: header + per-chunk nonce/ciphertext/tag; each chunk binds object ID,
chunk index, and final-chunk flag as associated data. Truncation/reordering is
rejected when reading sequentially to EOF.
"""
from __future__ import annotations
import os, secrets, struct
from pathlib import Path
from typing import BinaryIO, Iterator
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

MAGIC = b"CDENC2\x00"
KEY_BYTES = 32
NONCE_BYTES = 12
TAG_BYTES = 16
DEFAULT_CHUNK_SIZE = 1024 * 1024
MAX_CHUNK_SIZE = 8 * 1024 * 1024


def new_object_id() -> str:
    return secrets.token_hex(32)


def generate_data_key() -> bytes:
    return AESGCM.generate_key(bit_length=256)


def _aad(object_id: str, index: int, final: bool) -> bytes:
    return b"CyberDrive\x00" + object_id.encode("ascii") + struct.pack(">Q?", index, final)


def encrypt_stream(source: BinaryIO, destination: BinaryIO, data_key: bytes,
                   object_id: str, chunk_size: int = DEFAULT_CHUNK_SIZE) -> int:
    """Encrypt a stream with bounded memory; returns plaintext byte count."""
    if len(data_key) != KEY_BYTES: raise ValueError("data_key must be 32 bytes")
    if not (1 <= chunk_size <= MAX_CHUNK_SIZE): raise ValueError("invalid chunk size")
    if not object_id or not object_id.isascii(): raise ValueError("invalid object id")
    aes = AESGCM(data_key)
    destination.write(MAGIC + struct.pack(">I", chunk_size))
    total = index = 0
    # One-chunk lookahead allows a final flag to be authenticated.
    current = source.read(chunk_size)
    if not current:
        nonce = os.urandom(NONCE_BYTES)
        encrypted = aes.encrypt(nonce, b"", _aad(object_id, 0, True))
        destination.write(struct.pack(">I", 0) + nonce + encrypted + b"\x01")
        return 0
    while True:
        nxt = source.read(chunk_size)
        final = not nxt
        nonce = os.urandom(NONCE_BYTES)
        encrypted = aes.encrypt(nonce, current, _aad(object_id, index, final))
        destination.write(struct.pack(">I", len(current)) + nonce + encrypted + (b"\x01" if final else b"\x00"))
        total += len(current); index += 1
        if final: break
        current = nxt
    return total


def iter_decrypt_stream(source: BinaryIO, data_key: bytes, object_id: str) -> Iterator[bytes]:
    """Yield verified plaintext chunks. Consumers must read to EOF to verify finality."""
    if len(data_key) != KEY_BYTES: raise ValueError("data_key must be 32 bytes")
    if source.read(len(MAGIC)) != MAGIC: raise ValueError("invalid encrypted object header")
    raw = source.read(4)
    if len(raw) != 4: raise ValueError("truncated encrypted object header")
    chunk_size = struct.unpack(">I", raw)[0]
    if not (1 <= chunk_size <= MAX_CHUNK_SIZE): raise ValueError("invalid encrypted chunk size")
    aes = AESGCM(data_key); index = 0; saw_final = False
    while True:
        raw_len = source.read(4)
        if not raw_len:
            break
        if len(raw_len) != 4: raise ValueError("truncated chunk length")
        size = struct.unpack(">I", raw_len)[0]
        if size > chunk_size: raise ValueError("invalid chunk length")
        nonce = source.read(NONCE_BYTES)
        encrypted = source.read(size + TAG_BYTES)
        if len(nonce) != NONCE_BYTES or len(encrypted) != size + TAG_BYTES:
            raise ValueError("truncated encrypted chunk")
        # The authenticated final flag is determined by the on-disk chunk size.
        # Full chunks may still be final, so finality is encoded in a separate marker.
        marker = source.read(1)
        if len(marker) != 1 or marker not in (b"\x00", b"\x01"):
            raise ValueError("missing final-chunk marker")
        final = marker == b"\x01"
        plaintext = aes.decrypt(nonce, encrypted, _aad(object_id, index, final))
        if final:
            if source.read(1): raise ValueError("data found after final chunk")
            saw_final = True
            if plaintext: yield plaintext
            break
        if size == 0: raise ValueError("empty non-final chunk")
        yield plaintext; index += 1
    if not saw_final: raise ValueError("encrypted object is truncated")


def decrypt_stream(source: BinaryIO, destination: BinaryIO, data_key: bytes, object_id: str) -> int:
    total = 0
    for chunk in iter_decrypt_stream(source, data_key, object_id):
        destination.write(chunk); total += len(chunk)
    return total
