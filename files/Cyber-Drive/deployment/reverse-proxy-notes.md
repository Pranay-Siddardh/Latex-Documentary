# Reverse proxy deployment notes

- Terminate HTTPS at a maintained reverse proxy and set `CYBER_DRIVE_HTTPS=1` only when HTTPS is enforced.
- Proxy to Waitress bound to loopback; do not expose the development Flask server to the internet.
- Set a body-size limit appropriate for drive uploads; broadcast attachment handling has a separate 10 MiB limit.
- Configure proxy read/send timeouts for large uploads, and avoid logging cookies, authorization headers, OTPs, or full request bodies.
- Verify trusted proxy headers explicitly before using forwarded client IPs.
