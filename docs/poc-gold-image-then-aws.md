# Expansion Pack path: create gold image → PoC on AWS

**Full runbook (proven end-to-end, including pitfalls):** [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)

This is the **correct** Expansion Pack flow (not the earlier cloud-init-only PoC).

```text
Mac Terminal
    │
    ├─ 1. compose-on-builder.sh
    │       → RHEL builder EC2
    │       → local image-builder + fl-rhel-gold.toml
    │       → AMI registered in AWS  (gold image)
    │
    └─ 2. launch-gold-ami.sh
            → EC2 from that AMI
            → verify-remote.sh  (PoC)
```

All commands below run in **Mac Terminal**.

---

## 0. Clean up the old cloud-init PoC (optional but recommended)

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/aws
export PATH="/Users/ydandge/Documents/fedora-lane-core-pack-faster/.tools/aws-cli:$PATH"
./terminate-ec2.sh
```

Keep `env.local` (your RHDP keys).

---

## 1. Create the gold image (Image Builder on a builder EC2)

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/aws
export PATH="/Users/ydandge/Documents/fedora-lane-core-pack-faster/.tools/aws-cli:$PATH"

./compose-on-builder.sh
```

**Expect 45–120+ minutes.** Do not close the terminal.

When finished you should see `GOLD AMI = ami-...` and `output/gold-ami.json`.

If compose fails (e.g. RHEL 10 packages on RHEL 9 AMI), SSH to the builder from the script output and check logs.

---

## 2. PoC: launch a VM **from** that gold AMI

```bash
./launch-gold-ami.sh
# wait ~2 minutes for firstboot httpd
./verify-remote.sh
```

Manual check:

```bash
IP=$(python3 -c "import json;print(json.load(open('output/aws-outputs.json'))['public_ip'])")
curl -s "http://${IP}:35443/"
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$IP
```

On the VM:

```bash
getenforce
findmnt /var/log /home /tmp /var/tmp
findmnt -n -o OPTIONS /tmp | grep noexec
sudo firewall-cmd --list-all
sudo reboot
```

---

## 3. Tear down

```bash
./terminate-ec2.sh
# also terminate the builder if still running (ID in output/builder-outputs.json)
aws ec2 terminate-instances --instance-ids $(python3 -c "import json;print(json.load(open('output/builder-outputs.json'))['instance_id'])")
```

Then delete the RHDP OPEN environment in the browser.

---

## What this proves vs the earlier PoC

| | Cloud-init PoC (done) | This path |
|---|---|---|
| Gold AMI from Image Builder | No | **Yes** |
| Blueprint / compose | No | **Yes** |
| Separate mounts + noexec | Usually fail | **Should pass** |
| Expansion Pack story | Partial | **Full** |
