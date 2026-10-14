# Solution Overview — RHEL Golden Image + Insights for Fedora Lane  
## Junior Consultant · Core Pack · RHEL TDP (no Ansible)

## 1. Purpose

Establish a **production-shaped RHEL standard** for Fedora Lane’s hybrid Linux estate: one approved **golden image** built with **Image Builder**, registered to **Red Hat Insights**, with a clear Day-2 patch path for Critical/High CVEs. Prove the platform with a small **Boutique Inventory Sync** service running on that RHEL baseline.

This branch intentionally **does not use Ansible**. Day-0 consistency comes from the image; Day-2 comes from Insights + `dnf` security updates. Ansible can be a later phase once the team is ready.

## 2. Customer challenges addressed

| Core Pack challenge | How this RHEL solution addresses it |
|---|---|
| Siloed hybrid/multi-cloud ops | Same RHEL image pattern for NA DC, EMEA DC, boutiques, cloud Linux |
| Configuration drift (day 0) | Golden image — hosts are born the same |
| Automation friction | Fewer unique manual builds; Image Builder is the factory |
| Unpredictable envs block modernization | Known OS + packages under app services |
| Portability pain | Same baseline on-prem (qcow2) and cloud (AMI path) |
| COTS constraints | OS standardization under/around SAP & PoS — no SAP rip-and-replace |
| Security posture / audit | Insights client in image; vulnerability & compliance visibility |
| CVE “within days” | Insights + `dnf` security update runbook |

## 3. High-level architecture

```
Image Builder blueprint (Git)
        │
        ▼
  Compose → qcow2 / AMI / installer
        │
        ├─ Virginia DC VM (RHEL)
        ├─ Frankfurt DC VM (RHEL)
        ├─ Boutique closet VM (RHEL)
        └─ Cloud Linux (RHEL)
                │
                ├─ subscription-manager + insights-client
                └─ Podman → Boutique Inventory Sync (:8080)
```

## 4. Key design decisions

### Golden image first (not Ansible first)

**Why:** You can deliver consistency for Casey without writing automation code yet. Alex gets a reviewable artifact (blueprint in Git). Ren gets Insights on every new host.

### Image Builder over hand-built VMs

**Why:** Repeatable, versioned blueprint; supports multiple output types for Fedora Lane’s hybrid footprint.

### Insights for Day-2 visibility

**Why:** Core Pack demands fast Critical/High patching and better audit evidence. Insights is the RHEL-native answer without a custom CMDB project.

### Sample app = Inventory Sync (from Core Pack)

**Why:** Named custom tool (SAP ↔ PoS). Shows Cameron a portable service on the standard OS without touching SAP internals.

## 5. What we implemented

1. Image Builder blueprint — `solution/image-builder/fl-rhel-baseline.toml`  
2. Optional Kickstart — `solution/kickstart/fl-rhel-baseline.ks`  
3. Day-2 runbook — `docs/runbook-rhel-day2.md`  
4. Demo scripts — `solution/scripts/`  
5. Inventory Sync API — `solution/inventory-sync/`  
6. Presentation pack — Part 1 video + Part 2 live scripts  

## 6. Challenge → Solution → Demo mapping

| Challenge | Artifact | Demo moment |
|---|---|---|
| Drift at provision | Blueprint TOML | Walk packages/services/NTP |
| Hybrid outputs | Image Builder docs | qcow2 vs AMI mention |
| CVE / audit | Day-2 runbook + Insights | `insights-client` / updateinfo story |
| Modernization | Inventory-sync on RHEL/Podman | `curl /health` |
| No Ansible yet | This whole branch | Explicit “image now, Ansible later” |

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| No builder host in lab | Narrate blueprint + use stand-in RHEL VM; compose before live call |
| Config drift **after** day 0 | Call out Ansible/system roles as Phase 2 |
| Secrets in Kickstart | Placeholders only; activation keys via vault |
| Scope into PCI CHD | Pilot non-CHD boutiques/apps first with Ren |

## 8. Recommended next phase

1. Workshop with Casey: freeze RHEL version + package set for v1 image.  
2. First real compose → Virginia lab cluster.  
3. Insights dashboard review with Ren.  
4. Later: add Ansible Automation / system roles for ongoing drift — when you are ready.
