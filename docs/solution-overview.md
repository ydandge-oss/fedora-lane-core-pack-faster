# Solution Overview — RHEL Image Builder Gold Image  
## Server/Cloud OS Expansion Pack · Junior Consultant

## 1. Purpose

Give Fedora Lane a **secure, standardized RHEL gold image** for the e-commerce web fleet, addressing:

1. Inconsistent estate (~1,600 servers / mixed OS)  
2. Untraceable changes / long outages  
3. Ops skills gap for containers  

**Primary factory:** local **RHEL Image Builder** on a RHEL VM (blueprint → compose), following Red Hat’s [composing a customized RHEL system image](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description) procedure.

**Not** hosted Image Builder at console.redhat.com.

**Proven PoC runbooks:** [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md) · [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md)

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
              Local RHEL Image Builder
              fl-rhel-gold.toml (blueprint in Git)
                           │
              image-builder build ami | vhd
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
         AWS gold AMI              Azure gold VHD
         launch + verify           managed image + VM
              │                         │
              └────────────┬────────────┘
                           ▼
                 verify-remote.sh (+ reboot)
```

## 3. Challenge mapping

| Challenge | Image Builder response |
|---|---|
| Inconsistency | One blueprint → repeatable `ami`/`vhd` for the web tier |
| Untraceable changes | Hardened SSH/sudo baked in; versioned blueprint in Git |
| Container skills gap | httpd via Podman on firstboot (port 35443) |

## 4. What we implemented

| Area | Location |
|---|---|
| Blueprint + firstboot + compose | `solution/image-builder/` |
| AWS PoC automation | `solution/cloud/aws/` |
| Azure PoC automation | `solution/cloud/azure/` |
| Alternate factories | `solution/kickstart/`, `solution/image-mode/` |
| Verification | `solution/scripts/verify-gold-image.sh` + cloud `verify-remote.sh` |

**Proven:** AWS gold AMI and Azure gold VHD both passed Expansion Pack checks including reboot.

## 5. Recommended customer journey

1. Pilot Image Builder gold image on non-prod web (AWS **or** Azure — both paths exist).  
2. Keep Kickstart / Image Mode as alternate factories if the org prefers those workflows.  
3. Stretch: OpenSCAP CIS baseline on the same image.  

## 6. Demo plan

Live-prove Image Builder on cloud (SSH 2222, mounts, SELinux, curl 35443, verify).  
Show blueprint in Git.  
Scripts: [presentation-script-part1-video.md](./presentation-script-part1-video.md) · [presentation-script-part2-live.md](./presentation-script-part2-live.md).  
