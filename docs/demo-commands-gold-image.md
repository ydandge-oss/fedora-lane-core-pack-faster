# Demo cheat sheet — commands → gold image → VM

Put this on a second screen while recording Part 1.  
Full detail: [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md) · [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)

```text
Blueprint (Git)  →  Compose  →  Gold artifact  →  Launch  →  Gold VM  →  Verify
```

---

## Azure (pure path — what we proved)

```bash
cd solution/cloud/azure
cp -n env.example env.local    # AZURE_SUBSCRIPTION_ID (no secrets in Git)
az login
chmod +x *.sh

# 1) Build gold VHD (Image Builder on Azure RHEL builder)
./compose-vhd-on-azure-builder.sh
ssh -i ~/.ssh/fl-gold-poc.pem azureuser@<BUILDER_IP>
sudo rhc connect
exit
./compose-vhd-on-azure-builder.sh --continue <BUILDER_IP>

# If compose succeeded but upload missed the file:
./upload-vhd-from-azure-builder.sh <BUILDER_IP>

# 2) Gold artifact → Azure managed image
./create-image.sh

# 3) Gold VM from that image
./launch-vm.sh

# 4) Prove Expansion Pack on the PoC VM
./verify-remote.sh
az vm restart -g fl-gold-rg -n fl-rhel-gold-poc
./verify-remote.sh
```

**On the PoC VM:**

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<POC_IP>
getenforce
findmnt /var/log /home /tmp /var/tmp
findmnt -o OPTIONS /tmp
ss -tln | grep -E '2222|35443'
curl -s http://127.0.0.1:35443/ | head
```

**From laptop:** `curl -s http://<POC_IP>:35443/`

---

## AWS (same blueprint → gold AMI)

```bash
cd solution/cloud/aws
cp -n env.example env.local    # RHDP AWS keys (never commit)
export PATH="$PWD/../../.tools/aws-cli:$PATH"

# 1) Build gold AMI
./compose-on-builder.sh
# ssh ec2-user@<BUILDER_IP> && sudo rhc connect && exit
# ./continue-compose-on-builder.sh <BUILDER_IP>   # if needed

# 2) Gold VM from AMI
./launch-gold-ami.sh

# 3) Prove
./verify-remote.sh
```

---

## What each stage produces

| Stage | Command(s) | Output |
|---|---|---|
| Recipe | `fl-rhel-gold.toml` in Git | Expansion Pack controls |
| Compose | `compose-vhd-on-azure-builder` / `compose-on-builder` | `.vhd` or AMI |
| Register | `create-image.sh` / AMI auto-register | Cloud gold **image** |
| Launch | `launch-vm.sh` / `launch-gold-ami.sh` | **VM** from gold image |
| Prove | `verify-remote.sh` + reboot | Expansion Pack PASS |
