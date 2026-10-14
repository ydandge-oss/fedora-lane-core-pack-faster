# Solution Overview — Dual RHEL Gold Image Factories  
## Server/Cloud OS Expansion Pack · Junior Consultant

## 1. Purpose

Give Fedora Lane a **secure, standardized RHEL gold image** for the e-commerce web fleet, addressing:

1. Inconsistent estate (~1,600 servers / mixed OS)  
2. Untraceable changes / long outages  
3. Ops skills gap for containers  

We deliver **two manual factories** (neither uses hosted Image Builder):

| Path | Factory | Role |
|---|---|---|
| **A** | Kickstart | Fast, checklist-native gold image |
| **B** | RHEL 10 Image Mode (bootc) | Same controls; better path to operate at fleet scale |

## 2. Architecture

```text
                    Expansion Pack controls
                 (partitions, SELinux, 2222, 35443,
                  fladmins, firewall, httpd container)
                           │
           ┌───────────────┴───────────────┐
           ▼                               ▼
   Path A Kickstart                 Path B Image Mode
   fl-rhel-gold.ks                  Containerfile (rhel-bootc)
           │                               │
           ▼                               ▼
    libvirt / qemu-img              local bootc-image-builder
           │                               │
           └───────────────┬───────────────┘
                           ▼
              AWS or Azure Blank OPEN VM
                           │
                           ▼
                 verify-gold-image.sh
```

## 3. Challenge mapping

| Challenge | Both paths | Extra Image Mode value |
|---|---|---|
| Inconsistency | One RHEL web baseline | Registry-based OS updates toward 1,600 hosts |
| Untraceable changes | Hardened SSH + sudo | Immutable-root posture reduces snowflake edits |
| Container skills gap | httpd via Podman + systemd | OS itself is container-native (ops skill bridge) |

## 4. What we implemented

**Path A:** `solution/kickstart/fl-rhel-gold.ks` + harden/verify scripts + httpd container  
**Path B:** `solution/image-mode/` bootc Containerfile + `bib-config.toml` + build scripts  
**Shared:** cloud deploy docs, presentations, verification checklist  

## 5. Recommended customer journey

1. Pilot web tier with **Kickstart** gold image (Path A) on non-prod.  
2. Adopt **Image Mode** (Path B) for broader fleet consistency and Day-2 updates.  
3. Stretch: OpenSCAP CIS; dual AWS+Azure images.  

## 6. Demo plan

Live-prove **one** path on cloud; show the other path’s source and scale message.  
Scripts: `docs/presentation-script-part1-video.md` / `part2-live.md`.
