# Cyber Drive storage and room security design

## Personal-drive storage

Personal file contents are stored in a versioned `CDUSER1` envelope with a 32-byte local key, a clear length/opaque object ID header, and the authenticated chunk stream implemented in `storage_security/crypto.py`. The object ID and plaintext length are bound into the AES-GCM associated data. Each chunk uses a random nonce, an authenticated index, and an authenticated final-chunk marker. Truncation, chunk reordering, ciphertext modification, changed length, or changed object ID causes authentication/decryption failure when the affected chunk/stream is read.

The storage key is `.cyber_drive_storage_key` (0600 where supported), separate from uploaded content and excluded from source packages. If that key is absent while encrypted personal files are present, startup fails closed. A fresh install generates the key, then migrates existing regular files under `storage/` to encrypted contents using a temporary encrypted sibling and atomic replacement before accepting requests. A failed migration aborts startup, retains the original target where possible, and logs the relative path rather than contents. Back up the key separately from the encrypted data; without it, data is not recoverable.

All user reads/writes are routed through the personal-storage functions for upload, download, media/PDF byte ranges, source previews, Office conversion, subtitle extraction, bulk ZIP, folder ZIP, usage accounting, and admin file listing/deletion. Renames and deletions operate on the encrypted file bytes without decrypting. Byte-range serving decrypts only the authenticated chunks needed for that range, preserving seek performance without creating a plaintext media copy.

Office-format conversion and embedded-subtitle extraction use temporary decrypted input files only under `/dev/shm` (RAM-backed tmpfs). Those preview features fail closed if `/dev/shm` is unavailable. A production OS must still protect swap, crash dumps, backups, and process access; RAM-backed scratch space is not a substitute for full host security.

## Room sharing

- Room IDs are random 8-digit identifiers; room passwords use Werkzeug's adaptive password-hash format.
- Room chat messages are encrypted with AES-256-GCM and a domain-separated AAD string. Message content is excluded from transfer history.
- Room files are encrypted at rest using chunked AES-256-GCM. Opaque object IDs are used as stored object names; only the recipient can accept/download an offer; creator-only close; one active transfer per room.
- The room clock is stored in `last_transfer_at` for compatibility but represents *any relevant room activity*: chat message, file offer, accept/reject, transfer start, and completion/failure. Idle rooms are cleaned by a periodic reaper.
- `transfer_history` is separate from the room/transfer tables and intentionally has no cascading room foreign key; sender and receiver records survive room closure, are visible only to the matching authenticated account, and are retained for 10 days. It stores file transfer metadata and states, not chat contents.
- In-page send progress measures upload bytes received by the browser request; server-side encrypted write completion is reported separately. In-page receive progress is used for files up to 256 MiB. Larger downloads use the browser's native download manager to avoid buffering a multi-gigabyte plaintext Blob in JavaScript memory.

## Remaining deployment caveats

- This package's source-level crypto tests pass, but the build environment did not include Flask/Werkzeug and therefore did not permit live HTTP integration testing. Run the Flask app's route flows and manual regression checklist before real use.
- Local key files do not protect against a compromised host/root account. Production deployments should use KMS/HSM or equivalent protected key storage and a documented key rotation/recovery process.
- Room join/password guessing needs rate limiting. Validate concurrency under real WSGI deployment, proxy limits, long uploads/downloads, cancellation, media seeking, and migration backups before broader exposure.
- Use HTTPS for browser sessions outside a trusted isolated LAN, firewalls, restricted file permissions, encrypted backups, and updated dependencies.
