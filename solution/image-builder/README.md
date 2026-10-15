# Path Primary — RHEL Image Builder (local)

Official Expansion Pack gold-image factory using **local** RHEL Image Builder on a RHEL VM.

**Not** the hosted Image Builder at console.redhat.com.

## Upstream docs

- [RHEL image builder description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)
- [Creating system images with the CLI](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/creating-system-images-with-cli)

## Layout

| File | Purpose |
|---|---|
| `fl-rhel-gold.blueprint.toml` | Editable blueprint template |
| `files/fl-gold-firstboot.sh` | Firstboot: SELinux ports, `/tmp` noexec, httpd container |
| `fl-rhel-gold.toml` | Generated compose-ready blueprint |
| `scripts/install-image-builder.sh` | Install `image-builder` on builder VM |
| `scripts/generate-blueprint.sh` | Embed firstboot → `fl-rhel-gold.toml` |
| `scripts/compose.sh` | Compose `ami` / `vhd` / `qcow2` |

## Quick start (on a subscribed RHEL 10 builder VM)

```bash
sudo ./scripts/install-image-builder.sh
./scripts/generate-blueprint.sh

# Edit fl-rhel-gold.toml — replace AAAREPLACE_WITH_REAL_PUBLIC_KEY
# Optional: add password = "$(openssl passwd -6 'DemoPass')" for sudo demos

sudo ./scripts/compose.sh ami     # AWS
# or
sudo ./scripts/compose.sh vhd     # Azure
# or
sudo ./scripts/compose.sh qcow2   # local test
```

Full PoC: [`docs/poc-steps-image-builder.md`](../../docs/poc-steps-image-builder.md)

## What the blueprint encodes

- Separate mounts: `/var/log`, `/home`, `/tmp`, `/var/tmp` (each &lt; 5 GiB)
- Group `fladmins` + users `fladmin1` / `fladmin2` (SSH keys; passworded sudo)
- Firewall ports **2222** + **35443** only (default ssh service disabled)
- SSH drop-in: port 2222, no root, no password auth
- Firstboot: SELinux enforcing + port labels, `/tmp` noexec, Podman httpd on 35443

## Output formats (Expansion Pack)

| Cloud | `image-builder` type |
|---|---|
| AWS | `ami` |
| Azure | `vhd` |
| Local proof | `qcow2` |

```bash
image-builder list   # see all types
```
