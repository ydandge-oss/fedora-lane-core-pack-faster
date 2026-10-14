# PoC steps — Path B: RHEL 10 Image Mode (bootc)

Build the OS as a bootable container, convert **locally** to a disk, deploy to AWS or Azure Blank OPEN, verify Expansion Pack controls.

> This uses **local** `bootc-image-builder` via Podman.  
> It is **not** the hosted Image Builder service on console.redhat.com.

---

## Phase 0 — Prep

1. RHEL 10 builder host (RHDP or lab) with Podman.  
2. `podman login registry.redhat.io`  
3. Replace SSH public key in:  
   - `solution/image-mode/Containerfile`  
   - `solution/image-mode/bib-config.toml` (optional user key)  
4. Set admin passwords after first boot (or inject hashed passwords in a private build).  

```bash
cd /path/to/fedora-lane-core-pack-faster
git checkout expansion-tdp-solution
chmod +x solution/image-mode/scripts/*.sh
```

---

## Phase 1 — Build bootc gold OCI image

```bash
cd solution/image-mode
./scripts/build-bootc.sh
# produces: localhost/fl-rhel10-bootc-gold:latest
```

---

## Phase 2 — Convert to disk (local BIB)

```bash
# For AWS import often: raw or ami (per your OPEN env docs)
./scripts/build-disk.sh raw
# or: ./scripts/build-disk.sh qcow2
# or: ./scripts/build-disk.sh ami
```

Artifacts land in `solution/image-mode/output/` (gitignored).

`bib-config.toml` requests separate filesystems for `/var/log`, `/home`, `/tmp`, `/var/tmp` (each under 5 GiB). After boot, confirm with `findmnt` and set `/tmp` **noexec** if not already applied via `tmp.mount.d`.

---

## Phase 3 — Upload to cloud + provision VM

Same as Kickstart path after you have a disk:

- AWS Blank OPEN → import → AMI → launch → SG **2222** + **35443**  
  See `solution/cloud/aws-deploy.md`  
- Azure Blank OPEN → VHD/image → VM → NSG **2222** + **35443**  
  See `solution/cloud/azure-deploy.md`  

```bash
ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<CLOUD_IP>
```

---

## Phase 4 — Verify (same script as Kickstart)

Copy and run:

```bash
sudo bash solution/scripts/verify-gold-image.sh
curl -s http://127.0.0.1:35443/ | head
podman ps
getenforce
findmnt /var/log /home /tmp /var/tmp
sudo reboot
# re-verify after reboot
```

---

## Phase 5 — What to say in the presentation

“Path B uses **RHEL 10 Image Mode**: same Expansion Pack hardenings, but the OS is built as a bootc container so Fedora Lane can scale the same standard toward **1,600 servers** with transactional updates. We converted the image **locally** — not with hosted Image Builder.”

---

## Cleanup

- Delete OPEN environments / cloud VMs when done.  
- `rm -rf solution/image-mode/output`  
- Never commit registry passwords or cloud keys.  
