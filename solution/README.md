# Technical solutions — dual gold-image factories

| Path | Directory | Summary |
|---|---|---|
| **A — Kickstart** | [`kickstart/`](./kickstart/) | Classic Anaconda recipe → VM disk → cloud |
| **B — Image Mode** | [`image-mode/`](./image-mode/) | RHEL 10 `bootc` Containerfile → local BIB → cloud |

## Shared components

| Path | Used by |
|---|---|
| [`container/`](./container/) | Kickstart path httpd assets (Image Mode has its own `image-mode/html`) |
| [`systemd/`](./systemd/) | Kickstart Quadlet unit |
| [`scripts/verify-gold-image.sh`](./scripts/verify-gold-image.sh) | **Both** paths after cloud deploy |
| [`scripts/apply-runtime-hardening.sh`](./scripts/apply-runtime-hardening.sh) | Kickstart alternative (no KS) |
| [`cloud/`](./cloud/) | AWS / Azure OPEN import steps |
| [`openscap/`](./openscap/) | Stretch CIS |

## Which path for the live demo?

- **Safest checklist:** Path A Kickstart end-to-end on one cloud.  
- **Best scale narrative:** Path B Image Mode build + same verify script.  
- **Ideal:** Prove A or B fully; show the other in Git for 60–90 seconds.
