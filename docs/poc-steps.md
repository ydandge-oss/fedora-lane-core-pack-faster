# PoC steps — Server/Cloud OS Expansion Pack  
## Manual RHEL gold image → AWS or Azure → prove

Follow these phases in order. **Do not use the hosted Image Builder service** (console.redhat.com). Manual Kickstart / local VM build only.

**Environments (Expansion Pack):**  
- [AWS Blank OPEN](https://demo.redhat.com)  
- [Azure Blank OPEN](https://demo.redhat.com)  
Order with Activity: Practice/Enablement. Shut down when finished.

---

## Phase 0 — Prep (30–60 min)

1. Clone this branch and make the repo **private**; add `mflaim-eng`.  
2. Generate SSH key for gold-image admins (keep private key offline):  
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/fl-gold-admin -C "fladmin@fedorlane-gold"
   ```  
3. Put the **public** key into:  
   - `solution/kickstart/fl-rhel-gold.ks` (`authorized_keys` section)  
4. On a subscribed RHEL builder host (or RHDP RHEL VM used as builder), install tools:  
   ```bash
   sudo dnf install -y virt-install libvirt virt-viewer genisoimage \
     libguestfs-tools cloud-utils-growpart
   sudo systemctl enable --now libvirtd
   ```  
5. Obtain RHEL 9/10 install ISO (RHDP / Red Hat downloads — follow your program access).

---

## Phase A — Build gold image with Kickstart (manual)

### A1. Stage Kickstart

```bash
cd /path/to/fedora-lane-core-pack-faster
git checkout expansion-tdp-solution
# Edit solution/kickstart/fl-rhel-gold.ks — SSH keys + passwords
```

Create passwords for `fladmin1` / `fladmin2`:

```bash
openssl passwd -6 'YourStrongPasswordHere'
# paste hashes into Kickstart useradd/chpasswd section
```

### A2. Install VM via Kickstart (`virt-install` example)

```bash
sudo virt-install \
  --name fl-rhel-gold \
  --memory 4096 \
  --vcpus 2 \
  --disk size=40 \
  --location /path/to/rhel-9.iso \
  --initrd-inject=solution/kickstart/fl-rhel-gold.ks \
  --extra-args="inst.ks=file:/fl-rhel-gold.ks console=tty0" \
  --os-variant rhel9.0 \
  --network network=default \
  --noautoconsole
```

*(Adjust `--location` / `os-variant` for RHEL 10 if that is your target.)*

### A3. Alternative — install interactively then harden

If Kickstart networking is painful in your lab:

1. Install RHEL minimal with **custom partitioning** matching Expansion Pack mounts.  
2. Copy repo onto the VM.  
3. Run:
   ```bash
   sudo bash solution/scripts/apply-runtime-hardening.sh
   sudo bash solution/scripts/verify-gold-image.sh
   ```

### A4. First boot checks (on the gold VM)

```bash
sudo bash solution/scripts/verify-gold-image.sh
curl -s http://127.0.0.1:35443/ | head
ss -ltn | grep -E '2222|35443'
getenforce
findmnt /tmp /var/log /home /var/tmp
sudo reboot
# after reboot — re-run verify and curl again (must survive reboot)
```

### A5. Seal the image (before export)

```bash
sudo cloud-init clean --logs || true
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/systemd/random-seed
history -c
sudo poweroff
```

---

## Phase B — Export disk and upload to cloud

Pick **AWS or Azure** (stretch: both).

### B1. AWS (AMI)

On the libvirt host:

```bash
# Convert qcow2 → raw → volume suitable for import (example)
sudo qemu-img convert -f qcow2 -O raw /var/lib/libvirt/images/fl-rhel-gold.qcow2 fl-rhel-gold.raw
```

In **AWS Blank OPEN** (RHDP):

1. Create S3 bucket (or use lab bucket).  
2. Upload `fl-rhel-gold.raw` (or follow OPEN env’s import snapshot docs).  
3. **EC2 → Snapshots / AMI from snapshot** → register AMI `fl-rhel-gold`.  
4. Launch instance from AMI.  
5. Security group: **TCP 2222** and **TCP 35443** from your IP only.  
6. SSH: `ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<PUBLIC_IP>`

Detailed notes: [`../solution/cloud/aws-deploy.md`](../solution/cloud/aws-deploy.md)

### B2. Azure (VHD / Managed Image)

```bash
sudo qemu-img convert -f qcow2 -O vpc fl-rhel-gold.qcow2 fl-rhel-gold.vhd
# Azure requires fixed VHD — convert as needed per Microsoft docs
```

In **Azure Blank OPEN**:

1. Upload VHD to storage account.  
2. Create image / VM from that VHD.  
3. NSG: allow **2222** and **35443** from your IP.  
4. SSH on port 2222.

Details: [`../solution/cloud/azure-deploy.md`](../solution/cloud/azure-deploy.md)

---

## Phase C — Prove on cloud VM (demo evidence)

```bash
ssh -p 2222 fladmin1@<CLOUD_IP>
sudo ./verify-gold-image.sh   # copy script to VM first
curl -s http://127.0.0.1:35443/
# from laptop:
curl -s http://<CLOUD_IP>:35443/
sudo reboot
# re-verify after reboot
```

Capture for presentation:

- `lsblk` / `findmnt` showing four separate mounts  
- `getenforce` → Enforcing  
- `sshd` on 2222, httpd container on 35443  
- Browser hitting `http://<ip>:35443/`  
- `podman ps` showing httpd container  

---

## Phase D — Stretch goals (optional)

1. **OpenSCAP CIS** — see `solution/openscap/README.md`  
2. **Second cloud image** — repeat Phase B for the other cloud  

---

## Phase E — Presentation PoC flow (what you click during 15 min)

1. Architecture slide → 3 challenges.  
2. Show Kickstart snippet (partitions + ports).  
3. Live: SSH `:2222` into cloud VM.  
4. Live: `verify-gold-image.sh` or quick command cluster.  
5. Live: browser/`curl` `:35443` index page + `podman ps`.  
6. Value summary → one next step (standardize fleet on this gold image).  

Scripts:  
- Part 1 video → `docs/presentation-script-part1-video.md`  
- Part 2 live → `docs/presentation-script-part2-live.md`  

---

## Cleanup

- Terminate cloud VMs / delete OPEN environments when done.  
- Never leave RHDP credentials in Git.  
