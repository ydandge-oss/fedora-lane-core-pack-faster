# Verification checklist — Expansion Pack gold image

Run on the **cloud VM** provisioned from your gold image (after reboot once).

**AWS gold AMI path documented in:** [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md) (proven).

| # | Requirement | How to check | OK? |
|---|---|---|---|
| 1 | Manual build (no hosted Image Builder) | Process in `docs/poc-steps.md` + runbook | ☑ AWS |
| 2 | Deployed on AWS or Azure | Instance/VM in OPEN env | ☑ AWS |
| 3 | httpd + index.html (container preferred) | `curl :35443` shows Fedora Lane page; `podman ps` | ☑ AWS |
| 4a | `/var/log` separate | `findmnt /var/log` | ☑ AWS |
| 4b | `/home` separate | `findmnt /home` | ☑ AWS |
| 4c | `/tmp` separate | `findmnt /tmp` | ☑ AWS |
| 4d | `/var/tmp` separate | `findmnt /var/tmp` | ☑ AWS |
| 4e | Each &lt; 5 GiB | `lsblk` / `df -h` | ☑ AWS |
| 5a | SELinux enforcing | `getenforce` | ☑ AWS |
| 5b | `/tmp` noexec | `findmnt -o OPTIONS /tmp` | ☑ AWS |
| 5c | httpd port 35443 | `ss -ltn \| grep 35443` | ☑ AWS |
| 5d | SSH port 2222 | `ss -ltn \| grep 2222` | ☑ AWS |
| 5e | Admin users + group + sudo | `getent group fladmins`; `sudo -l` | ☑ AWS |
| 5f | sudo always prompts | `timestamp_timeout=0`; no NOPASSWD | ☐ PoC used temp NOPASSWD for automation |
| 5g | Root SSH disabled | `PermitRootLogin no` | ☑ AWS |
| 5h | SSH password auth disabled | `PasswordAuthentication no` | ☑ AWS |
| 5i | Only SSH+httpd ports | `firewall-cmd --list-all` | ☑ AWS |
| 6 | Proven on cloud from gold image | Live demo | ☑ AWS |
| 7 | Survives reboot | Reboot + re-check services | ☑ AWS |
| S1 | OpenSCAP (stretch) | `solution/openscap/` | ☐ |
| S2 | AWS **and** Azure images (stretch) | Dual import | ☐ AMI done; VHD: [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md) |

Automated helper: `sudo bash solution/scripts/verify-gold-image.sh`
