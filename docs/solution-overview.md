# Solution Overview — RHEL Image Builder Gold Image  
## Server/Cloud OS Expansion Pack · Junior Consultant

## 1. Purpose

Give Fedora Lane a **secure, standardized RHEL gold image** for the e-commerce web fleet, addressing:

1. Inconsistent estate (~1,600 servers / mixed OS)  
2. Untraceable changes / long outages  
3. Ops skills gap for containers  

**Primary factory:** local **RHEL Image Builder** on a RHEL VM (blueprint → compose), following Red Hat’s [composing a customized RHEL system image](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description) procedure.

**Not** hosted Image Builder at console.redhat.com.

**Proven AWS PoC runbook:** [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)

| Path | Factory | Role |
|---|---|---|
| **Primary** | Local RHEL Image Builder | Official Expansion Pack compose path (`ami` / `vhd`) |
| Alt A | Kickstart | Classic Anaconda recipe (fallback) |
| Alt B | RHEL 10 Image Mode (bootc) | Container-native OS updates at fleet scale |

## 2. Architecture

```text
                    Expansion Pack controls
                 (partitions, SELinux, 2222, 35443,
                  fladmins, firewall, httpd container)
                           │
                           ▼
              Local RHEL Image Builder VM
              fl-rhel-gold.toml (blueprint)
                           │
              image-builder build ami|vhd|qcow2
                           │
                           ▼
              AWS or Azure Blank OPEN VM
                           │
                           ▼
                 verify-gold-image.sh
```

## 3. Challenge mapping

| Challenge | Image Builder response |
|---|---|
| Inconsistency | One blueprint → repeatable `ami`/`vhd` for the web tier |
| Untraceable changes | Hardened SSH/sudo baked in; versioned blueprint in Git |
| Container skills gap | httpd via Podman + systemd on firstboot |

## 4. What we implemented

**Primary:** `solution/image-builder/` — blueprint, firstboot, install/compose scripts  
**Alts:** Kickstart + Image Mode (same Expansion Pack controls)  
**Shared:** cloud deploy docs, presentations, `verify-gold-image.sh`

## 5. Recommended customer journey

1. Pilot web tier with **Image Builder** gold image on non-prod (AWS or Azure).  
2. Keep Kickstart / Image Mode as alternate factories if the org prefers those workflows.  
3. Stretch: OpenSCAP CIS; dual AWS+Azure images.  

## 6. Demo plan

Live-prove **Image Builder** on cloud; show blueprint + compose in Git.  
Scripts: `docs/presentation-script-part1-video.md` / `part2-live.md`.
