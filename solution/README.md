# Technical solution — RHEL Golden Image + Insights Pilot  
## No Ansible required

Practice build for Fedora Lane when the TDP option is **RHEL** and automation coding (Ansible) is out of scope for now.

## Components

| Path | Purpose |
|---|---|
| [image-builder/](./image-builder/) | Image Builder blueprint (TOML) for an approved RHEL golden image |
| [kickstart/](./kickstart/) | Optional Kickstart snippet aligned to the same baseline |
| [scripts/](./scripts/) | Helper scripts: validate blueprint locally, demo checklist |
| [inventory-sync/](./inventory-sync/) | Sample Boutique Inventory Sync API to run **on** the RHEL host |
| [docs pointers](../docs/runbook-rhel-day2.md) | Day-2: register, patch, Insights |

## What “good” looks like in the demo

1. Show the **blueprint** → explain what is baked into every new host.  
2. Show (or narrate) **Image Builder** compose → qcow2/AMI/ISO artifact.  
3. Boot a lab RHEL VM from that image (or a stand-in RHEL VM with the same packages).  
4. Show **subscription-manager** + **Insights** registration story.  
5. Run **inventory-sync** on that host and curl `/health`.  
6. Map each step to Core Pack challenges (drift, CVE patching, audit, modernization).

## Quick start — sample app (works on laptop or RHEL)

```bash
cd inventory-sync
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export SYNC_API_TOKEN=demo-not-a-real-secret
uvicorn app.main:app --host 127.0.0.1 --port 8080
# other terminal:
curl -s http://127.0.0.1:8080/health
```

## Image Builder (on a RHEL builder host)

```bash
# On RHEL with osbuild-composer / cockpit-image-builder installed
sudo composer-cli blueprints push image-builder/fl-rhel-baseline.toml
sudo composer-cli blueprints list
sudo composer-cli compose start fl-rhel-baseline qcow2
# Wait, then download the image — see image-builder/README.md
```

If you do not have a builder host yet, walk through the blueprint file and Day-2 runbook in the presentation; still meet the “what/why” bar, and lab the compose before the live call if possible.

## Secrets

- Never commit activation keys, pull secrets, or Insights auth tokens.  
- Use placeholders in Kickstart / cloud-init examples.  
