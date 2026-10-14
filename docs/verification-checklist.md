# Verification checklist — Expansion Pack gold image

Run on the **cloud VM** provisioned from your gold image (after reboot once).

| # | Requirement | How to check | OK? |
|---|---|---|---|
| 1 | Manual build (no hosted Image Builder) | Process in `docs/poc-steps.md` | ☐ |
| 2 | Deployed on AWS or Azure | Instance/VM in OPEN env | ☐ |
| 3 | httpd + index.html (container preferred) | `curl :35443` shows Fedora Lane page; `podman ps` | ☐ |
| 4a | `/var/log` separate | `findmnt /var/log` | ☐ |
| 4b | `/home` separate | `findmnt /home` | ☐ |
| 4c | `/tmp` separate | `findmnt /tmp` | ☐ |
| 4d | `/var/tmp` separate | `findmnt /var/tmp` | ☐ |
| 4e | Each &lt; 5 GiB | `lsblk` / `df -h` | ☐ |
| 5a | SELinux enforcing | `getenforce` | ☐ |
| 5b | `/tmp` noexec | `findmnt -o OPTIONS /tmp` | ☐ |
| 5c | httpd port 35443 | `ss -ltn \| grep 35443` | ☐ |
| 5d | SSH port 2222 | `ss -ltn \| grep 2222` | ☐ |
| 5e | Admin users + group + sudo | `getent group fladmins`; `sudo -l` | ☐ |
| 5f | sudo always prompts | `timestamp_timeout=0`; no NOPASSWD | ☐ |
| 5g | Root SSH disabled | `PermitRootLogin no` | ☐ |
| 5h | SSH password auth disabled | `PasswordAuthentication no` | ☐ |
| 5i | Only SSH+httpd ports | `firewall-cmd --list-all` | ☐ |
| 6 | Proven on cloud from gold image | Live demo | ☐ |
| 7 | Survives reboot | Reboot + re-check services | ☐ |
| S1 | OpenSCAP (stretch) | `solution/openscap/` | ☐ |
| S2 | AWS **and** Azure images (stretch) | Dual import | ☐ |

Automated helper: `sudo bash solution/scripts/verify-gold-image.sh`
