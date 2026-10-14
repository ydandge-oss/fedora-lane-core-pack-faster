# Hybrid cloud PoC — replicate Fedora Lane (AWS EC2 + optional Azure)

Fedora Lane’s Core Pack uses **AWS (primary)** and **Azure (secondary)**.  
**AWS path uses Amazon EC2 via AWS CLI — not Terraform.**

```
  Image Builder blueprint (intent)
            │
            ▼
  cloud-init baseline (same file)
            │
     ┌──────┴──────┐
     ▼             ▼
  AWS EC2       Azure VM (optional)
  launch-ec2.sh terraform optional
     │             │
     └──────┬──────┘
            ▼
   ./poc/run-poc.sh --remote
```

## AWS EC2 (primary — no Terraform)

Full steps: [`aws/README.md`](./aws/README.md)

```bash
# 1. Install + configure AWS CLI
aws configure

# 2. Launch EC2 with Fedora Lane baseline user-data
cd poc/cloud/aws
cp env.example env.local    # set KEY_NAME, SSH_CIDR, SSH_PRIVATE_KEY
./launch-ec2.sh

# 3. Wait ~2-3 minutes for cloud-init, then verify
#    curl http://<PUBLIC_IP>:8080/health

# 4. Inventory + PoC evidence
cd ../../..
./poc/cloud/scripts/write-inventory.sh
./poc/run-poc.sh --remote

# 5. Tear down
./poc/cloud/aws/terminate-ec2.sh
```

## Azure (optional second cloud)

Still available under [`azure/`](./azure/) if you want full multi-cloud.  
You can demo **AWS-only** — `write-inventory.sh` accepts a single EC2 host.

## What the EC2 instance proves

| Customer challenge | EC2 PoC proof |
|---|---|
| Hybrid / cloud Linux sprawl | Real AWS server with approved baseline |
| Drift / snowflakes | `/etc/fl-baseline/MARKER` matches blueprint intent |
| Modernization | Inventory Sync API on `:8080` |
| Security starting point | Insights client installed when image allows |

## Prerequisites

- AWS account + **AWS CLI** + EC2 key pair  
- `ssh_cidr` = your IP `/32`  
- Never commit `env.local`, `.pem`, or access keys  

## Legacy Terraform (AWS)

Not used by default. Kept only under [`aws/terraform-optional/`](./aws/terraform-optional/) if you prefer IaC later.
