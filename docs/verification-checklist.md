# Verification checklist — Expansion Pack gold image

Run on the **cloud VM** provisioned from your gold image (after reboot once).

**Proven runbooks:**
- AWS AMI: [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)
- Azure VHD: [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md)

| # | Requirement | How to check | OK? |
|---|---|---|---|
| 1 | Manual build (no hosted Image Builder) | Process in `docs/poc-steps.md` + runbooks | ☑ AWS · ☑ Azure |
| 2 | Deployed on AWS or Azure | Instance/VM in OPEN env | ☑ AWS · ☑ Azure |
| 3 | httpd + index.html (container preferred) | `curl :35443` shows Fedora Lane page; `podman ps` | ☑ AWS · ☑ Azure |
| 4a | `/var/log` separate | `findmnt /var/log` | ☑ AWS · ☑ Azure |
| 4b | `/home` separate | `findmnt /home` | ☑ AWS · ☑ Azure |
| 4c | `/tmp` separate | `findmnt /tmp` | ☑ AWS · ☑ Azure |
| 4d | `/var/tmp` separate | `findmnt /var/tmp` | ☑ AWS · ☑ Azure |
| 4e | Each &lt; 5 GiB | `lsblk` / `df -h` | ☑ AWS · ☑ Azure |
| 5a | SELinux enforcing | `getenforce` | ☑ AWS · ☑ Azure |
| 5b | `/tmp` noexec | `findmnt -o OPTIONS /tmp` | ☑ AWS · ☑ Azure |
| 5c | httpd port 35443 | `ss -ltn \| grep 35443` | ☑ AWS · ☑ Azure |
| 5d | SSH port 2222 | `ss -ltn \| grep 2222` | ☑ AWS · ☑ Azure |
| 5e | Admin users + group + sudo | `getent group fladmins`; `sudo -l` | ☑ AWS · ☑ Azure |
| 5f | sudo always prompts | `timestamp_timeout=0`; no NOPASSWD | ☐ PoC used temp NOPASSWD for automation |
| 5g | Root SSH disabled | `PermitRootLogin no` | ☑ AWS · ☑ Azure |
| 5h | SSH password auth disabled | `PasswordAuthentication no` | ☑ AWS · ☑ Azure |
| 5i | Only SSH+httpd ports | `firewall-cmd --list-all` | ☑ AWS · ☑ Azure |
| 6 | Proven on cloud from gold image | Live demo | ☑ AWS · ☑ Azure |
| 7 | Survives reboot | Reboot + re-check services | ☑ AWS · ☑ Azure |
| S1 | OpenSCAP (stretch) | `solution/openscap/` | ☐ |
| S2 | AWS **and** Azure images (stretch) | Dual import | ☑ AMI + ☑ VHD |

Automated helper: `sudo bash solution/scripts/verify-gold-image.sh`
