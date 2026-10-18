# Runbook — Local Image Builder gold VHD + Azure PoC

**Status:** Scripts ready; run after ordering **Azure Blank OPEN**.  
**Where:** Mac Terminal.  
**Factory:** same blueprint as AWS AMI (`solution/image-builder/fl-rhel-gold.toml`).

Upstream: [RHEL image builder description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

---

## Architecture

```text
Mac Terminal
  │
  ├─► Builder EC2 (RHDP AWS) — Image Builder compose type azure/vhd
  │     → upload .vhd to S3  (staging)
  │
  └─► Azure Blank OPEN
        download VHD → page blob → managed image → VM
        SSH 2222 / fladmin1 · httpd 35443 · verify
```

Image Builder still runs on **RHEL** (AWS builder). Azure only **imports** the VHD.

---

## Phase A — Compose the gold VHD

Needs RHDP **AWS Blank OPEN** (builder + S3). Reuse the same `solution/cloud/aws/env.local` as the AMI PoC.

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/aws
export PATH="/Users/ydandge/Documents/fedora-lane-core-pack-faster/.tools/aws-cli:$PATH"

# New builder + VHD only:
./compose-vhd-on-builder.sh

# Or reuse an existing builder IP (faster if Image Builder already installed):
# ./compose-vhd-on-builder.sh <BUILDER_PUBLIC_IP>
```

**Before compose succeeds**, builder must be RHSM-subscribed:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem ec2-user@<BUILDER_IP>
sudo rhc connect
exit
# then: ./compose-vhd-on-builder.sh <BUILDER_IP>
```

**Success:** `output/gold-vhd.json` lists an `s3_uri`, e.g. `s3://fl-gold-…/gold/something.vhd`.

Manual alternative on any subscribed RHEL 10 builder:

```bash
cd solution/image-builder
sudo ./scripts/compose.sh vhd
```

---

## Phase B — Azure Blank OPEN + import

1. Order **Azure Blank OPEN** on demo.redhat.com; copy subscription ID (and login method).  
2. Install CLI: `brew install azure-cli`  
3. Configure:

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/azure
cp -n env.example env.local
# Edit env.local: AZURE_SUBSCRIPTION_ID, AZURE_LOCATION, SSH_PRIVATE_KEY
chmod +x *.sh
az login   # or set AZURE_CLIENT_ID / SECRET / TENANT_ID in env.local
```

4. Upload → image → VM:

```bash
# Auto-download from S3 if aws/output/gold-vhd.json exists and AWS env is set:
./upload-vhd.sh

# Or explicit path:
# ./upload-vhd.sh ../aws/output/your-file.vhd

./create-image.sh
./launch-vm.sh
# wait ~4–5 minutes
./verify-remote.sh
```

5. Spot checks:

```bash
IP=$(python3 -c "import json;print(json.load(open('output/azure-outputs.json'))['public_ip'])")
curl -s "http://${IP}:35443/"
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$IP
```

6. Survive reboot:

```bash
az vm restart -g "$AZURE_RESOURCE_GROUP" -n "$VM_NAME"
# wait, then ./verify-remote.sh again
```

---

## Phase C — Cleanup

```bash
./cleanup.sh              # delete PoC VM
# ./cleanup.sh --group    # delete whole resource group
```

Terminate AWS VHD builder if still running (`aws/output/vhd-builder-outputs.json`).  
Delete both RHDP OPEN environments when finished.

---

## Scripts

| Script | Purpose |
|---|---|
| `aws/compose-vhd-on-builder.sh` | Image Builder → Azure-ready VHD → S3 |
| `azure/upload-vhd.sh` | Page-blob upload (+ raw/qcow2→fixed VHD if needed) |
| `azure/create-image.sh` | Managed disk + image from VHD URI |
| `azure/launch-vm.sh` | VM from gold image + NSG 2222/35443 + custom-data |
| `azure/verify-remote.sh` | Expansion Pack checks |
| `azure/cleanup.sh` | Tear down VM / resource group |

---

## Pitfalls

| Symptom | Fix |
|---|---|
| `no valid subscriptions` on compose | `sudo rhc connect` on builder |
| `cannot find … rhel-10` | Use versioned distro (`rhel-10.x`); `compose.sh` auto-detects |
| Azure rejects VHD | Must be **fixed** `.vhd` page blob (script converts raw/qcow2) |
| SSH timeout | NSG / `SSH_CIDR` must match your current public IP |
| Wrong ports | Gold image uses **2222**, not 22 |

---

## Related

- [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md) — AMI path (already proven)  
- [poc-steps-image-builder.md](./poc-steps-image-builder.md) — blueprint  
- [solution/cloud/azure/README.md](../solution/cloud/azure/README.md)  
