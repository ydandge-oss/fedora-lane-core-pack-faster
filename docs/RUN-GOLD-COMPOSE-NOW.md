# Run now — compose gold AMI + VHD, then PoC

**Full documented process:** [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)

**Where:** your **Mac Terminal** (this Cursor agent cannot reach AWS from its sandbox).

**Time:** compose often takes **1–2 hours**. Keep the laptop awake.

---

## 1. Prepare

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/aws
export PATH="/Users/ydandge/Documents/fedora-lane-core-pack-faster/.tools/aws-cli:$PATH"

# Stop the earlier cloud-init PoC VM if still running
./terminate-ec2.sh || true
```

Confirm AWS works:

```bash
set -a; source env.local; set +a
export AWS_DEFAULT_REGION="$AWS_REGION"
aws sts get-caller-identity
```

---

## 2. Compose gold images (AMI + VHD)

```bash
./compose-on-builder.sh
```

What this does:
1. Launches a large **RHEL builder** EC2  
2. Installs **local Image Builder**  
3. Composes **`ami`** (uploads/registers as gold AMI in AWS)  
4. Composes **`vhd`** (uploads to `s3://…/gold/` for Azure)  

When done, note:
- `GOLD AMI = ami-…`  
- `output/gold-ami.json`  
- VHD path under `s3://…/gold/`

---

## 3. AWS PoC from the gold AMI

```bash
./launch-gold-ami.sh
# wait ~2–5 minutes for firstboot (httpd)
./verify-remote.sh

IP=$(python3 -c "import json;print(json.load(open('output/aws-outputs.json'))['public_ip'])")
curl -s "http://${IP}:35443/"
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$IP
```

On the VM, prove mounts too:

```bash
findmnt /var/log /home /tmp /var/tmp
getenforce
sudo reboot
```

---

## 4. Azure PoC from the gold VHD

Full steps: [`azure-gold-vhd-poc-runbook.md`](./azure-gold-vhd-poc-runbook.md)

```bash
# Compose VHD only (if not already in S3):
./compose-vhd-on-builder.sh

cd ../azure
cp -n env.example env.local   # fill Azure Blank OPEN subscription
./upload-vhd.sh && ./create-image.sh && ./launch-vm.sh && ./verify-remote.sh
```

---

## 5. Cleanup

```bash
./terminate-ec2.sh
# builder ID:
python3 -c "import json;print(json.load(open('output/builder-outputs.json'))['instance_id'])"
aws ec2 terminate-instances --instance-ids <builder-id>
```

Delete RHDP environments when finished.
