# Technical solution — Fedora Lane RHEL Gold Image

Manual gold image for the **Server/Cloud OS** Expansion Pack (Junior Consultant).

## Layout

| Path | Purpose |
|---|---|
| [`kickstart/fl-rhel-gold.ks`](./kickstart/fl-rhel-gold.ks) | Full Kickstart implementing partitions + security baseline |
| [`container/`](./container/) | Podman httpd (port **35443**) + `index.html` |
| [`scripts/`](./scripts/) | Post-build helpers + verification |
| [`systemd/`](./systemd/) | Units so container starts at boot |
| [`openscap/`](./openscap/) | Stretch goal notes |
| [`cloud/`](./cloud/) | AWS / Azure import + VM prove steps |

## Build principle

1. **Kickstart** installs RHEL with required disks, packages, and firstboot hooks.  
2. **%post** applies SSH/httpd/firewall/SELinux/sudo/users.  
3. **Podman** runs httpd from local Containerfile (or UBI httpd).  
4. Export disk → **AMI** (AWS) or **VHD** (Azure) → provision VM → verify.

Detailed steps: [`../docs/poc-steps.md`](../docs/poc-steps.md).

## Admin accounts (change passwords before production)

Kickstart creates group `fladmins` and users `fladmin1`, `fladmin2`.  
Passwords are **placeholders** — set real ones offline; never commit live secrets.

Default practice password pattern (change immediately): see Kickstart comments.
