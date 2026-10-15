# Technical solutions — Expansion Pack gold image

| Path | Directory | Summary |
|---|---|---|
| **Primary — Image Builder** | [`image-builder/`](./image-builder/) | Local RHEL `image-builder` CLI: blueprint → `ami`/`vhd`/`qcow2` |
| Alt A — Kickstart | [`kickstart/`](./kickstart/) | Classic Anaconda recipe → VM disk → cloud |
| Alt B — Image Mode | [`image-mode/`](./image-mode/) | RHEL 10 `bootc` Containerfile → local BIB → cloud |

## Shared components

| Path | Used by |
|---|---|
| [`container/`](./container/) | Kickstart path httpd assets |
| [`systemd/`](./systemd/) | Kickstart Quadlet unit |
| [`scripts/verify-gold-image.sh`](./scripts/verify-gold-image.sh) | **All** paths after cloud deploy |
| [`scripts/apply-runtime-hardening.sh`](./scripts/apply-runtime-hardening.sh) | Kickstart alternative (no KS) |
| [`cloud/`](./cloud/) | AWS / Azure OPEN import steps |
| [`openscap/`](./openscap/) | Stretch CIS |

## Which path for the live demo?

- **Required / primary:** Image Builder end-to-end on one cloud (matches Expansion Pack + Red Hat docs).  
- Kickstart / Image Mode: backup story or scale narrative if asked.
