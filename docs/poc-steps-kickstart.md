# PoC steps — Path A: Kickstart gold image

Manual RHEL gold image via Kickstart → export disk → AWS or Azure Blank OPEN → verify.

> **Do not** use the hosted Image Builder service (console.redhat.com).

---

## Phase 0 — Prep (30–60 min)

1. Clone branch `expansion-tdp-solution`; make repo private; add `mflaim-eng`.  
2. Generate SSH key:  
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/fl-gold-admin -C "fladmin@fedorlane-gold"
   ```  
3. Put the **public** key into `solution/kickstart/fl-rhel-gold.ks`.  
4. On a subscribed RHEL builder:  
   ```bash
   sudo dnf install -y virt-install libvirt virt-viewer genisoimage libguestfs-tools
   sudo systemctl enable --now libvirtd
   ```  
5. Obtain RHEL install ISO (RHDP / downloads).

---

## Phase A — Build with Kickstart

```bash
cd /path/to/fedora-lane-core-pack-faster
# Edit Kickstart: SSH keys + set admin passwords (openssl passwd -6 ...)

sudo virt-install \
  --name fl-rhel-gold \
  --memory 4096 \
  --vcpus 2 \
  --disk size=40 \
  --location /path/to/rhel.iso \
  --initrd-inject=solution/kickstart/fl-rhel-gold.ks \
  --extra-args="inst.ks=file:/fl-rhel-gold.ks console=tty0" \
  --os-variant rhel9.0 \
  --network network=default \
  --noautoconsole
```

### Alternative — interactive install + harden script

1. Custom partitioning for `/var/log`, `/home`, `/tmp`, `/var/tmp` (&lt; 5 GiB).  
2. Copy repo onto VM.  
3. Run:
   ```bash
   sudo bash solution/scripts/apply-runtime-hardening.sh
   sudo bash solution/scripts/verify-gold-image.sh
   ```

### First boot checks

```bash
sudo bash solution/scripts/verify-gold-image.sh
curl -s http://127.0.0.1:35443/ | head
ss -ltn | grep -E '2222|35443'
getenforce
findmnt /tmp /var/log /home /var/tmp
sudo reboot
# re-verify after reboot
```

### Seal before export

```bash
sudo cloud-init clean --logs || true
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/systemd/random-seed
history -c
sudo poweroff
```

---

## Phase B — Export + cloud

```bash
sudo qemu-img convert -f qcow2 -O raw /var/lib/libvirt/images/fl-rhel-gold.qcow2 fl-rhel-gold.raw
```

- AWS: `solution/cloud/aws-deploy.md`  
- Azure: `solution/cloud/azure-deploy.md`  

SG/NSG: TCP **2222** and **35443** from your IP only.

```bash
ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<PUBLIC_IP>
curl -s http://<PUBLIC_IP>:35443/
```

---

## Phase C — Demo evidence

- `lsblk` / `findmnt`  
- `getenforce`  
- `podman ps` + browser `:35443`  
- `verify-gold-image.sh`  
- Reboot persistence  

---

## Cleanup

Terminate cloud VMs / delete OPEN environments. No credentials in Git.
