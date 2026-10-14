# Fedora Lane — Server/Cloud OS TDP  
## Junior Consultant · Expansion Pack Solution

**Program:** FASTER CY26/27  
**TDP:** Server / Cloud OS  
**Customer:** Fedora Lane (fictional)  
**Branch:** `expansion-tdp-solution`  
**GitHub:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster  

> Private repo preferred for submission. Add **`mflaim-eng`** for viewing access.  
> Never commit AWS/Azure/RHDP credentials, passwords, or private keys.

---

## What this branch delivers (Expansion Pack)

A **manually built RHEL gold image** for Fedora Lane’s e-commerce web server fleet that addresses:

1. **Inconsistent server environment** (~1,600 servers; mixed OS)  
2. **Untraceable admin changes / extended outages**  
3. **Ops skills gap for container workloads**  

| Deliverable | Location |
|---|---|
| Technical solution (gold image assets) | [`solution/`](./solution/) |
| PoC steps (build → cloud → verify) | [`docs/poc-steps.md`](./docs/poc-steps.md) |
| Solution overview | [`docs/solution-overview.md`](./docs/solution-overview.md) |
| Part 1 video script (15 min) | [`docs/presentation-script-part1-video.md`](./docs/presentation-script-part1-video.md) |
| Part 2 live script (15 min) | [`docs/presentation-script-part2-live.md`](./docs/presentation-script-part2-live.md) |
| Slides outline | [`docs/presentation-slides.md`](./docs/presentation-slides.md) |
| Follow-up email | [`docs/follow-up-email.md`](./docs/follow-up-email.md) |
| Verification checklist | [`docs/verification-checklist.md`](./docs/verification-checklist.md) |

---

## Gold image specs (Expansion Pack checklist)

- [x] **Manual** gold image (no hosted Image Builder service) — Kickstart + documented virt build  
- [x] Deployable on **AWS or Azure**  
- [x] **httpd** + dummy `index.html` — **in a container** (Podman)  
- [x] Separate partitions (&lt; 5 GiB each): `/var/log`, `/home`, `/tmp`, `/var/tmp`  
- [x] SELinux **enforcing**  
- [x] `/tmp` **noexec**  
- [x] httpd on **35443** (SELinux port)  
- [x] SSH on **2222** (SELinux port)  
- [x] Admin users + group + sudo  
- [x] sudo **always** prompts for password  
- [x] Root SSH disabled  
- [x] SSH password auth disabled  
- [x] Firewall: only SSH + httpd ports  
- [x] Survive reboot; services enable at boot  
- [ ] Stretch: OpenSCAP CIS — see `solution/openscap/`  
- [ ] Stretch: AWS **and** Azure images — see cloud docs  

---

## Quick start

1. Read [`docs/poc-steps.md`](./docs/poc-steps.md) end-to-end.  
2. Build the image on a RHEL builder host using Kickstart (`solution/kickstart/`).  
3. Upload/import to **AWS Blank OPEN** or **Azure Blank OPEN** (RHDP).  
4. Provision a VM from the gold image; run [`solution/scripts/verify-gold-image.sh`](./solution/scripts/verify-gold-image.sh).  
5. Rehearse Part 1 / Part 2 scripts with a timer.  

```bash
git checkout expansion-tdp-solution
# On a RHEL builder (not this laptop alone):
# see docs/poc-steps.md Phase A–D
```

---

## Important Expansion Pack rules

| Do | Don’t |
|---|---|
| Create gold image **manually** (Kickstart / local compose) | Use **hosted** Image Builder (console.redhat.com service) |
| Use RHDP **AWS/Azure Blank OPEN** | Commit cloud/RHDP credentials |
| Shut down OPEN envs when done | Leave instances running after demo |

---

## Branch map

| Branch | Purpose |
|---|---|
| `main` | Early Core Pack Ansible pilot |
| `rhel-image-builder-insights` | Practice Image Builder path (superseded for graded TDP) |
| **`expansion-tdp-solution`** | **Official Expansion Pack gold-image solution** |
