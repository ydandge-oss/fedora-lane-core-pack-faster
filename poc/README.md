# Proof of Concept — Fedora Lane RHEL Golden Image Pilot

**Branch:** `rhel-image-builder-insights`  
**Goal:** Prove, in a short demo, that an approved RHEL baseline + portable app pattern addresses Fedora Lane’s Core Pack challenges — **without Ansible**.

## What this PoC proves

| Claim | How the PoC shows it |
|---|---|
| Day-0 consistency beats snowflake builds | Side-by-side **snowflake vs baseline** host profiles |
| Baseline is defined as code | Image Builder blueprint validated from Git |
| Apps can run on the standard platform | Boutique Inventory Sync API healthy on the baseline |
| Security / audit story starts at birth | Simulated Insights registration + evidence report |
| Hybrid sites share one standard | Same baseline applied to modeled VA / Frankfurt / boutique / cloud hosts |

## Two ways to run

### A. Laptop PoC (no Podman / no RHEL builder) — **recommended for Part 1 recording**

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster
./poc/run-poc.sh
```

This will:

1. Validate the Image Builder blueprint  
2. Compare snowflake vs baseline profiles  
3. Start the inventory-sync API locally  
4. Hit `/health`, `/api/v1/sync/status`, and a secured sync run  
5. Write an evidence pack under `poc/output/`

### B. UBI container PoC (RHEL-like runtime via Podman)

```bash
# once per machine
podman machine init   # if needed
podman machine start

./poc/run-poc.sh --container
```

Builds `poc/Containerfile` (UBI 9) as a **stand-in** for the golden image, runs inventory-sync inside it, prints evidence.

> Full Image Builder compose (`composer-cli`) still needs a real RHEL builder host. This PoC proves the *pattern*; lab compose is the production-shaped next step (see `solution/image-builder/README.md`).

## Demo script (≈ 5 minutes inside your 15-min talk)

```bash
./poc/run-poc.sh
# then show:
open poc/output/evidence-report.md   # or cat it
```

Talk track:

1. “Snowflake hosts look different per site — that’s Fedora Lane today.”  
2. “Baseline profile matches our Image Builder blueprint.”  
3. “Same app works on the baseline — modernization on a predictable OS.”  
4. “Evidence report is what we’d show Alex, Casey, and Ren.”  

## Outputs

After a successful run:

```
poc/output/
  evidence-report.md    ← show this in the presentation
  evidence.json         ← machine-readable summary
  poc.log               ← full run log
```

## Cleanup

```bash
./poc/run-poc.sh --cleanup
```
