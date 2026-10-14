# Solution Overview — RHEL Gold Image for Fedora Lane  
## Server/Cloud OS Expansion Pack · Junior Consultant

## 1. Purpose

Design and demonstrate a **secure, standardized, operationally resilient RHEL gold image** that becomes the foundation for Fedora Lane’s **e-commerce web server fleet**. The image is built **manually** (Kickstart / local VM — not hosted Image Builder), deployed to **AWS or Azure**, and proven to survive reboot with all Expansion Pack controls in place.

## 2. Challenges addressed (Expansion Pack)

| Challenge | Pain today | How the gold image helps |
|---|---|---|
| **1. Inconsistent server environment** | ~1,600 servers; Rocky/Ubuntu/CentOS Stream/Amazon Linux; patch fails on 600+ hosts | One **RHEL** birth certificate for web tier; same packages, partitions, SELinux, ports everywhere |
| **2. Untraceable changes / long outages** | Undocumented SSH tweaks; high MTTR | Hardened SSH (key-only, non-standard port, no root); sudo always authenticated; consistent baseline reduces “mystery drift.” Pair with Session Recording / Web Console in ops phase |
| **3. Container skills gap** | Complex `podman run` typos; ops depend on developers | **httpd runs as a container** managed by **systemd/Quadlet** — start/stop/status like any service, not a fragile one-liner |

## 3. Architecture

```
Kickstart (manual) → Gold disk image
        │
        ▼
   Import AMI (AWS)  or  VHD image (Azure)
        │
        ▼
   Cloud VM from gold image
        ├─ SSH :2222 (keys, no root, no passwords)
        ├─ Podman httpd container :35443
        ├─ SELinux enforcing
        ├─ /var/log /home /tmp(noexec) /var/tmp separate LVs
        └─ firewalld: only 2222 + 35443
```

## 4. Design decisions

| Decision | Why |
|---|---|
| Manual Kickstart | Expansion Pack forbids hosted Image Builder |
| httpd **in container** | Meets “if possible” ask + addresses Challenge 3 with systemd-managed Podman |
| Ports 2222 / 35443 | Spec + reduces noisy scanning on defaults |
| Separate small volumes | Protect root from log/tmp fill-up |
| fladmins + passworded sudo | Least privilege + accountability |
| AWS **or** Azure first | Meets must-have; second cloud is stretch |

## 5. Challenge → demo mapping

| Challenge | Demo moment |
|---|---|
| Inconsistency | Show identical marker + mounts + ports on cloud VM from gold image |
| Outage / change risk | Show SSH hardening + sudo rules; explain reduced snowflake surface |
| Containers | `podman ps` + `systemctl status fl-httpd` + curl :35443 |

## 6. Fleet context (Expansion Pack numbers)

| Location | Approx. count |
|---|---:|
| On-prem VMs | 900 |
| AWS + Azure | 600 |
| Boutiques | 100 |
| **Total** | **~1,600** |

This gold image is the **web-tier standard** to stop OS diversity and failed mass patching.

## 7. Next phase recommendations

1. Roll gold image to non-prod web fleet; measure patch success rate.  
2. Enable **Session Recording** + Web Console for Challenge 2 visibility.  
3. Pipeline rebuilds when CVEs land (still manual-compose friendly).  
4. Stretch: CIS via OpenSCAP; dual AWS+Azure images.  
