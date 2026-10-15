# 5–7 minute script — Part 1 (Video)  
## Primary: RHEL Image Builder gold image

**Audience:** Casey Novak / Alex Lee (and SME reviewers)  
**Topic:** Server/Cloud OS TDP — Expansion Pack

---

## Hook (0:30)

“Fedora Lane’s e-commerce web fleet is inconsistent across ~1,600 servers. Expansion Pack asks for a **manual** RHEL gold image — not hosted Image Builder. We built that with **local RHEL Image Builder** on a builder VM.”

---

## Problem → Want (1:00)

- Mixed OS / snowflake hosts → one RHEL web baseline  
- Untraceable changes → blueprint in Git + hardened SSH/sudo  
- Container skills gap → httpd runs in a container on the gold image  

---

## Solution (2:30)

Show Git: `solution/image-builder/fl-rhel-gold.toml`

1. **Blueprint** — packages, LVM mounts (`/var/log`, `/home`, `/tmp`, `/var/tmp`), `fladmins`, firewall 2222/35443, SSH drop-in  
2. **Compose** — `image-builder build ami` or `vhd` on a subscribed RHEL 10 VM  
3. **Firstboot** — SELinux ports, `/tmp` noexec, Podman httpd on **35443**  
4. **Prove** — cloud VM + `verify-gold-image.sh` + reboot  

Cite Red Hat: composing a customized RHEL system image / image-builder CLI.

---

## Demo evidence (1:30)

Screen: SSH `-p 2222`, `getenforce`, `findmnt`, `curl :35443`, firewall list, verify script output.

---

## Close (0:30)

“Next step: pilot this Image Builder AMI/VHD on non-prod web. Repo link and live demo in Part 2.”
