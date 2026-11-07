# Cyber Drive — encrypted personal storage + private rooms

This is a **configured private deployment bundle** of the full Flask project. It includes the saved SMTP settings in `.env` and the previously configured admin identity/settings under `.admin/`, restored from the prior private package. It excludes regular-user account records, uploaded files, runtime logs, and encryption/session keys. Treat this ZIP as secret: do not publish it, commit it to source control, or share it publicly.

## What is implemented

- Personal-drive files are encrypted at rest using chunked AES-256-GCM. Uploads are encrypted before the final logical filename appears; existing plaintext files inside `storage/` are migrated at startup, before HTTP requests are served. The migration fails closed if a file cannot be encrypted.
- Personal file downloads and media/PDF byte-range requests decrypt only authenticated chunks on demand. File previews, bulk ZIP, folder ZIP, quota accounting, rename/delete, and the admin client-file manager use the encrypted-storage paths.
- Office document conversion and MKV subtitle extraction use short-lived decrypted input copies only on Linux `/dev/shm` (tmpfs). Those previews are disabled rather than writing a plaintext scratch file to a regular disk if `/dev/shm` is unavailable.
- Sharing-room files use the separate encrypted room-object store; chat text is separately encrypted at rest. Room idle activity is reset by chat messages and file transfer actions. Transfer History records file sends/receives only, not chat messages, and persists after room closure for 10 days.
- File sharing includes room passwords, random 8-digit room IDs, participant lists, recipient acceptance, creator-only room closure, user-side upload/download progress, persistent transfer history, and admin-configurable enablement/active-room limit.
- The admin dashboard places compact File sharing and Storage requests panels under User profiles. Room/participant management opens a large modal. Each user row has separate “Delete user + data” and “Delete data only” actions. Admin logs and password management share one compact Admin tools panel. Favicon links are included across HTML sub-sites.

## Important key management

On first launch, Cyber Drive creates `.cyber_drive_storage_key` with owner-only permissions. It is deliberately not included in this ZIP. **Back up this key securely and separately immediately after first launch.** If the key is lost, the personal files encrypted with it cannot be recovered. If encrypted files exist but the key is missing, startup fails closed rather than generating a replacement key and pretending the files are readable. The room-sharing key is stored separately at `data/sharing/sharing.key` and must also be backed up securely.

Do not put either key into source control or a source ZIP. Treat the key plus its corresponding encrypted data as a single backup/recovery set. Local key files protect data at rest against exposure of the storage files alone, not against a compromised server/root account. For stronger production key protection, use a managed KMS/HSM with a tested recovery process. Encrypt swap and backups, restrict OS access, and rotate/replace any credentials that may have been disclosed previously.

## Configured SMTP and admin profile

- The saved SMTP settings are restored in `.env`. The ZIP contains the actual configured values, so keep it private and retain `chmod 600 .env` on the deployed filesystem. `python verify_smtp.py` checks whether the settings exist and tests connection/TLS/authentication without sending an email.
- The saved admin identity/password hash and admin storage settings are restored in `.admin/.admin_credentials.json` and `.admin/.admin_settings.json`. Sign in through the shared Cyber Drive login screen using the configured admin identity. The password itself is not stored in plaintext; use the dashboard password-management control to change it.
- If environment variables for `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, or `MAIL_FROM` are set by your shell/service, they take precedence over `.env`. Remove stale overrides if the restored settings still appear not to work.

## Deploy safely

1. Create a virtual environment and install `requirements.txt`.
2. Keep `.env` and the `.admin/` directory private (`chmod 600 .env`, `chmod 700 .admin`, `chmod 600 .admin/.admin_credentials.json .admin/.admin_settings.json`).
3. Start from a valid working directory using `python main.py` (or the supplied Waitress/service setup for a controlled LAN deployment).
4. Use one consistent site address in the browser. Switching between a LAN IP, `localhost`, and a hostname creates separate browser sessions and can cause session/CSRF checks to reject forms. A stale form now redirects back for refresh instead of showing a raw CSRF Bad Request page; AJAX/API clients receive a readable stale-token error.
5. Do not overwrite an existing installation before backing it up. The ZIP intentionally excludes `.cyber_drive_secret`, `.cyber_drive_storage_key`, `data/sharing/sharing.key`, the user database, and uploaded files. When updating an existing installation, **preserve those key files and your existing data**. If encrypted files already exist, restore the matching encryption keys; do not generate new keys for old ciphertext.
6. Confirm admin login and SMTP verification, then test sign-up, upload, preview and download on the target server. Do not expose the service outside a trusted LAN until HTTPS, firewalling, rate limits, backup/restore and load tests are complete.

## Validation notes

The test suite was run from the build source before creating this slim deployment ZIP: `python -m pytest -q tests` — 18 passed. Test files are intentionally omitted from this deployment bundle. Python compilation and ZIP integrity are checked on the packaged source. Flask/Werkzeug are unavailable in the build environment, so a live Flask client/server integration test was not possible here; run the routes and browser flows on your target server before relying on production use.
