# How to build and run  
## Fedora Lane Expansion Pack — RHEL gold image (local Image Builder)

**Branch:** `expansion-tdp-solution`  
**Not** hosted Image Builder at console.redhat.com.

Official: [Creating system images with Image Builder CLI](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/assembly_creating-system-images-with-image-builder-cli)

---

## Prerequisites

- A **RHEL 10** host with local Image Builder (`image-builder` package / CLI)  
  — or use our scripts to launch a builder EC2 / Azure VM  
- **AWS** credentials with permission to use S3 and EC2 (never commit them)  
  — for Azure path: Azure Blank OPEN credentials instead  
- Network access to **Red Hat repositories** on the builder (RHSM: `sudo rhc connect`)  
- SSH key for gold admins (we use `~/.ssh/fl-gold-poc.pem`)

---

## Build (high level)

On a RHEL 10 builder — install once:

```bash
sudo dnf install -y image-builder
# optional GUI: sudo dnf install -y cockpit-image-builder
```

List AMI-capable distros (must show e.g. `rhel-10.0 type:ami` — **not** bare `rhel-10`):

```bash
sudo image-builder list | grep rhel-10 | grep x86_64 | grep ami
```

Use our blueprint (repo path):

```bash
cd /path/to/fedora-lane-core-pack-faster/solution/image-builder
./scripts/generate-blueprint.sh
# Set distro= in fl-rhel-gold.toml to the EXACT id from the list (script often auto-sets)
```

Compose AMI only (disk stays on the builder):

```bash
sudo ./scripts/compose.sh ami
# same as:
# sudo image-builder build ami \
#   --blueprint ./fl-rhel-gold.toml \
#   --distro rhel-10.2
```

---

## Build + upload to AWS (example)

```bash
sudo image-builder build ami \
  --blueprint ./fl-rhel-gold.toml \
  --distro rhel-10.2 \
  --aws-region us-east-2 \
  --aws-bucket fl-gold-<ACCOUNT>-us-east-2 \
  --aws-ami-name fl-rhel-gold
```

Needs IAM role **`vmimport`** in the account (our helper):

```bash
cd ../cloud/aws
./setup-vmimport-role.sh
```

**Easiest path (Mac → scripts do builder + compose + upload):**

```bash
cd solution/cloud/aws
cp -n env.example env.local    # put AWS keys — never commit
./setup-vmimport-role.sh
./compose-on-builder.sh
# on builder if asked: sudo rhc connect
# then: ./continue-compose-on-builder.sh <BUILDER_IP>
```

---

## Upload an existing `.raw` (example)

If compose already produced a disk file but AMI register failed:

```bash
sudo image-builder upload \
  /path/to/your-image.raw \
  --to=aws \
  --aws-region us-east-2 \
  --aws-bucket fl-gold-<ACCOUNT>-us-east-2 \
  --aws-ami-name fl-rhel-gold
```

Or from your Mac (script finds `.raw` on the builder):

```bash
cd solution/cloud/aws
./reupload-ami-from-builder.sh <BUILDER_IP>
```

Confirm AMI:

```bash
aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold \
  --output table
```

Expect **State = available** (example: `ami-07cb8e42f8e34bc14`).

---

## Publish to AWS + prove

Prefer Image Builder AWS upload (commands above), **or**  
`aws s3 cp` → import-snapshot → register-image → run-instances.

**Launch PoC from gold AMI:**

```bash
cd solution/cloud/aws
./launch-gold-ami.sh
# wait ~4–5 min for firstboot / Podman pull
./verify-remote.sh
```

Security group must allow **your IP** on **2222** and **35443**.

Then:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<PUBLIC_IP>
```

Simple checks ([`verification-checklist.md`](./verification-checklist.md)):

```bash
getenforce
findmnt /var/log /home /tmp /var/tmp
findmnt -n -o OPTIONS /tmp | grep noexec
ss -tln | grep -E '2222|35443'
curl -s http://127.0.0.1:35443/ | head
exit
curl -s http://<PUBLIC_IP>:35443/
```

**Console / plain CLI launch:** [`launch-gold-image-cli-and-console.md`](./launch-gold-image-cli-and-console.md) · [`solution/cloud/aws/README.md`](../solution/cloud/aws/README.md)

**Dummy boutique app** (update without new AMI):

```bash
cd solution/demo-app
./deploy-to-vm.sh <PUBLIC_IP>
```

---

## Azure (same blueprint → VHD)

```bash
cd solution/cloud/azure
cp -n env.example env.local
./compose-vhd-on-azure-builder.sh
# on builder: sudo rhc connect , then --continue
./create-image.sh
./launch-vm.sh
./verify-remote.sh
```

Full guide: [`azure-gold-vhd-poc-runbook.md`](./azure-gold-vhd-poc-runbook.md)

---

## Day-2 operations (end-user view)

- **New web server** = launch from the gold AMI / Azure image (no snowflake install)  
- **Admins** connect with keys on **2222** as named users (`fladmin1` / `fladmin2`)  
- **Site** answers on **35443**; httpd runs as a **container** (systemd unit when firstboot succeeds)  
- **Security baseline** is already on: SELinux, firewall, partitions, sudo / fladmins  
- **App updates** = deploy files onto the httpd volume (`solution/demo-app/deploy-to-vm.sh`) — no new gold image  
- **OS / hardening updates** = edit blueprint → compose **new** gold AMI → replace VMs in waves  
- Gold firewall still allows only **2222** and **35443**

---

## Recommended next step

1. Pilot this RHEL gold AMI / Azure image on **non-prod** web nodes  
2. Use Launch Template / ASG (AWS) or Scale Sets / Gallery (Azure) for new capacity  
3. Automate rebuilds from Git; optional Red Hat Insights at fleet scale  
4. Stretch: OpenSCAP CIS on the same factory; Kickstart / Image Mode remain as alternate factories in this repo  

**Ask:** Approve non-prod pilot using the Image Builder gold image as the web OS standard.

---

## More docs

| Doc | Purpose |
|---|---|
| [`aws-gold-ami-poc-runbook.md`](./aws-gold-ami-poc-runbook.md) | Numbered AWS create-AMI steps |
| [`azure-gold-vhd-poc-runbook.md`](./azure-gold-vhd-poc-runbook.md) | Azure VHD path |
| [`where-when-why-commands.md`](./where-when-why-commands.md) | Where / when / why for each command |
| [`solution-overview.md`](./solution-overview.md) | Architecture ↔ Fedora Lane challenges |
| [`customer-presentation-fedora-lane.md`](./customer-presentation-fedora-lane.md) | Google Slides deck |
| Root [`README.md`](../README.md) | Repo map + quick start |
