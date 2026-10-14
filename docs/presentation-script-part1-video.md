# 15-minute script — Part 1 (Video)  
## Dual path: Kickstart + Image Mode

**Presenter:** Yash Dandge  
**Submit:** Server/Cloud OS TDP + GitHub `expansion-tdp-solution`

> Pre-record: one cloud VM fully working (Path A **or** B). Have the other path open in the IDE.

---

## Opening (1:30)

“Fedora Lane has about **1,600 servers** on mixed Linux — patches fail, changes aren’t traceable, and containers stress ops.

I’m Yash Dandge. We designed **two manual gold-image factories** — **Kickstart** and **RHEL 10 Image Mode** — neither uses hosted Image Builder. I’ll prove one live on cloud and show how both meet the Expansion Pack.”

---

## Walkthrough (8:00)

### 1. Dual-path diagram (1:00)

Show `docs/kickstart-vs-image-mode.md` or architecture from solution overview.

“Kickstart = install recipe. Image Mode = bootable OS container converted locally to a disk.”

### 2. Live prove primary path (5:00)

SSH `:2222` → `verify-gold-image.sh` → `curl :35443` → `podman ps` → mounts / SELinux.

### 3. Secondary path in Git (2:00)

If primary was Kickstart, open `solution/image-mode/Containerfile` + `build-bootc.sh`.  
If primary was Image Mode, open `solution/kickstart/fl-rhel-gold.ks`.

“Same ports, users, httpd container, firewall — different factory. Image Mode is how we’d scale Day-2 across the fleet.”

---

## Value (3:00)

| Challenge | Message |
|---|---|
| Inconsistency | One RHEL web gold image |
| Change / MTTR | Hardened SSH + sudo |
| Containers | httpd as systemd service |
| Scale | Image Mode for ~1,600-host future |

---

## Closing (1:30)

“Pilot with Kickstart or Image Mode on OPEN cloud; standardize the web tier; grow Image Mode for fleet updates.

Repo: `expansion-tdp-solution`. Thank you.”
