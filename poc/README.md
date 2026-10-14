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

## Ways to run

### A. Laptop PoC — **recommended for Part 1 recording**

```bash
./poc/run-poc.sh
```

Validates blueprint, compares snowflake vs baseline, starts inventory-sync locally, writes `poc/output/evidence-report.md`.

### B. UBI container PoC (Podman)

```bash
podman machine start   # if needed
./poc/run-poc.sh --container
```

### C. AWS EC2 PoC — **replicates Fedora Lane cloud Linux (no Terraform)**

```bash
# AWS CLI required: aws configure
cd poc/cloud/aws
cp env.example env.local    # KEY_NAME, SSH_CIDR, SSH_PRIVATE_KEY
./launch-ec2.sh

# wait 2–3 min for cloud-init, then:
cd ../../..
./poc/cloud/scripts/write-inventory.sh
./poc/run-poc.sh --remote

# when finished:
./poc/cloud/aws/terminate-ec2.sh
```

Optional second cloud (Azure): see [cloud/README.md](./cloud/README.md).  
AWS EC2 details: [cloud/aws/README.md](./cloud/aws/README.md)

> Full Image Builder compose (`composer-cli`) still needs a real RHEL builder host for qcow2/AMI factory demos. Cloud VMs prove the *same baseline across AWS + Azure* — matching the customer’s hybrid story.

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
