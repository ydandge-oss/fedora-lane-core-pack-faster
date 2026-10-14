# Hybrid cloud PoC — replicate Fedora Lane (AWS + Azure)

Fedora Lane’s Core Pack footprint includes **AWS (primary e-commerce)** and **Azure (secondary)**. This folder lets you stand up **two RHEL (or RHEL-compatible) servers** that receive the **same baseline** as the Image Builder blueprint, then prove the app works on both.

```
                    ┌─────────────────────┐
  Git blueprint ───►│ Same day-0 baseline │
                    └─────────┬───────────┘
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        AWS EC2 RHEL    Azure RHEL VM    (optional lab/on-prem)
        us-east-1       westeurope
              │               │
              └───────┬───────┘
                      ▼
              Inventory Sync :8080
              + Insights story
```

## What you will create

| Host | Cloud | Mimics Fedora Lane |
|---|---|---|
| `fl-poc-aws-ecom` | AWS EC2 | Cloud Linux for e-commerce-style workload |
| `fl-poc-azure-analytics` | Azure VM | Secondary Azure footprint (EMEA-style region) |

Both use the same [`cloud-init/fl-rhel-baseline.yaml`](./cloud-init/fl-rhel-baseline.yaml) so the PoC shows **one standard across clouds** — the opposite of today’s snowflake Ubuntu/Amazon Linux mix.

## Prerequisites

- AWS account + credentials (`aws configure` or env vars)  
- Azure account + `az login`  
- Terraform `>= 1.5`  
- An SSH key pair (public key path for Terraform)  
- **RHEL subscription / pull secret story** for real RHEL images (see notes below)  
- **Never commit** access keys, `.tfvars` with secrets, or private keys  

## Quick path

### 1. Copy example variables

```bash
cp poc/cloud/aws/terraform.tfvars.example poc/cloud/aws/terraform.tfvars
cp poc/cloud/azure/terraform.tfvars.example poc/cloud/azure/terraform.tfvars
# edit both: region, key name / admin username, SSH public key
```

### 2. Create AWS host

```bash
cd poc/cloud/aws
terraform init
terraform apply
terraform output -json > ../../output/aws-outputs.json
```

### 3. Create Azure host

```bash
cd poc/cloud/azure
terraform init
terraform apply
terraform output -json > ../../output/azure-outputs.json
```

### 4. Build remote inventory and verify

```bash
cd ../../..   # repo root
./poc/cloud/scripts/write-inventory.sh
./poc/run-poc.sh --remote
```

`--remote` SSHes to AWS + Azure, checks baseline markers, and curls inventory-sync on each host.

### 5. Tear down (cost control)

```bash
cd poc/cloud/aws && terraform destroy
cd ../azure && terraform destroy
```

## Image choice (important)

| Option | When to use |
|---|---|
| **RHEL 9 BYOS/PAYG** AMI / Azure Marketplace | Closest to real Fedora Lane + Image Builder story |
| **Rocky / Alma 9** (RHEL-compatible) | Fine for practice if you lack RHEL cloud entitlements |
| **UBI container only** (`./poc/run-poc.sh --container`) | Laptop demo without VMs |

Terraform defaults use **official RHEL 9** lookups where possible; override AMI / image in `tfvars` if your account needs Marketplace terms acceptance.

## Cost / safety

- Use **small** instance sizes (`t3.small` / `Standard_B1s`)  
- Destroy after the demo  
- Restrict SSH (`ssh_cidr` = your IP `/32`)  
- Do not open `0.0.0.0/0` longer than the live call  

## Mapping to customer challenges

| Challenge | Hybrid PoC proof |
|---|---|
| Hybrid / multi-cloud silos | Same cloud-init baseline on AWS **and** Azure |
| Drift | Both hosts show identical `/etc/fl-baseline/MARKER` |
| Portability | Same inventory-sync API on both clouds |
| Security visibility | Insights client installed (register with real account in lab) |
