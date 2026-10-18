# Runbook — Pure Azure gold image (VHD)

**Status:** Proven on RHDP Azure Blank OPEN (verify + reboot PASS).  
**Goal:** Expansion Pack gold image on **Azure only** (no AMI required).  
**Artifact:** local Image Builder → **`.vhd`** → managed image → PoC VM.  
**Where:** Mac Terminal + Azure Blank OPEN.

Upstream: [RHEL image builder description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

---

## Architecture

```text
Mac Terminal
  │
  ├─► Builder RHEL VM (Azure Blank OPEN)
  │     sudo rhc connect
  │     image-builder compose vhd
  │     azcopy → page blob in same subscription
  │
  └─► PoC VM from managed image
        SSH 2222 · httpd 35443 · verify + reboot
```

---

## End-to-end steps (proven)

### 1. Azure Blank OPEN + CLI

```bash
brew install azure-cli
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/azure
cp -n env.example env.local
```

In `env.local` set (from demo.redhat.com Azure Blank OPEN):

```bash
AZURE_SUBSCRIPTION_ID=<from OPEN>
AZURE_LOCATION=eastus          # or region shown in OPEN
SSH_PRIVATE_KEY=~/.ssh/fl-gold-poc.pem
```

Leave `AZURE_CLIENT_SECRET` empty — use interactive login:

```bash
az login
az account set --subscription "$(grep '^AZURE_SUBSCRIPTION_ID=' env.local | cut -d= -f2)"
chmod +x *.sh
```

### 2. Compose gold VHD on Azure builder

```bash
./compose-vhd-on-azure-builder.sh
```

When prompted for RHSM:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem azureuser@<BUILDER_IP>
sudo rhc connect
exit
./compose-vhd-on-azure-builder.sh --continue <BUILDER_IP>
```

Compose often takes **45–120 minutes**.

If compose prints `Image build successful` but the script says `no .vhd produced`, the VHD is on the builder — upload it:

```bash
./upload-vhd-from-azure-builder.sh <BUILDER_IP>
# default path: /var/fl-image-builder/rhel-*-vhd-x86_64/*.vhd
```

### 3. Create image + launch PoC VM

```bash
./create-image.sh
./launch-vm.sh
```

Wait ~4–5 minutes for cloud-init / httpd.

### 4. Verify + reboot

```bash
./verify-remote.sh
az vm restart -g fl-gold-rg -n fl-rhel-gold-poc
# wait ~3 minutes
./verify-remote.sh
```

### 5. Cleanup

```bash
./cleanup.sh                 # PoC VM
# ./cleanup.sh --group       # entire resource group (builder + image + storage)
```

Delete the RHDP Azure Blank OPEN when finished.

---

## Scripts (`solution/cloud/azure/`)

| Script | Purpose |
|---|---|
| `compose-vhd-on-azure-builder.sh` | RHEL builder → Image Builder → VHD → page blob |
| `upload-vhd-from-azure-builder.sh` | Upload existing builder `.vhd` if compose finder failed |
| `create-image.sh` | Managed disk + image from VHD URI |
| `launch-vm.sh` | PoC VM + NSG 2222/35443 + custom-data |
| `verify-remote.sh` | Expansion Pack checks |
| `cleanup.sh` | Tear down |

Blueprint: `solution/image-builder/fl-rhel-gold.toml`

---

## Pitfalls (proven fixes)

| Symptom | Fix |
|---|---|
| `Builder is not RHSM-subscribed` | `sudo rhc connect` on builder, then `--continue` |
| `No space left on device` on `/home` | RHEL cloud LVM: grow `/var` (script does this; or manual `lvextend`) |
| `ERROR: no .vhd produced` after success | VHD under `/var/fl-image-builder/...` — run `upload-vhd-from-azure-builder.sh` |
| `azcopy: command not found` | Re-run upload script (installs official azcopy) |
| Azure CLI `latin-1` / `\u2014` | Keep firstboot/custom-data ASCII (fixed in launch-vm) |
| Verify `Address already in use` on 35443 | httpd already up — verify skips second container (fixed) |
| Wrong `az login` subscription | `az account set` to OPEN subscription (`pool-01-…`) |

---

## Expansion Pack checklist (Azure)

- [x] Manual gold image via **local** Image Builder (`vhd`)  
- [x] Deployable on **Azure**  
- [x] Separate `/var/log`, `/home`, `/tmp`, `/var/tmp`  
- [x] `/tmp` **noexec**  
- [x] SELinux **enforcing**  
- [x] SSH **2222**, key-only, no root  
- [x] httpd **container** on **35443**  
- [x] `fladmins` + admin users  
- [x] Survives **reboot**  

---

## Related

- [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md) — AWS AMI path (optional / separate)  
- [poc-steps.md](./poc-steps.md) — path index  
- [solution/cloud/azure/README.md](../solution/cloud/azure/README.md)  
