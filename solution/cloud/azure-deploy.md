# Deploy gold image on Azure (Blank OPEN)

**Full runbook:** [`docs/azure-gold-vhd-poc-runbook.md`](../../docs/azure-gold-vhd-poc-runbook.md)  
**Scripts:** [`solution/cloud/azure/`](./azure/)

## Goal

Import the Image Builder **VHD** as a managed image, create a VM, open **2222** and **35443**, prove Expansion Pack checks.

## Steps with project scripts

1. **Compose VHD** on an Azure builder (preferred):

   ```bash
   cd solution/cloud/azure
   ./compose-vhd-on-azure-builder.sh
   # rhc connect on builder if asked, then --continue <IP>
   ./create-image.sh
   ./launch-vm.sh
   ./verify-remote.sh
   ```

2. Reboot with `az vm restart`, re-verify, then `./cleanup.sh`.

## Launch gold image **without** scripts (CLI + Console)

If managed image `fl-rhel-gold` already exists and you do not want `./launch-vm.sh`:

- Copy-paste CLI + Portal steps: [`azure/README.md`](./azure/README.md) section **Launch from gold image without project scripts**
- Shared guide: [`docs/launch-gold-image-cli-and-console.md`](../../docs/launch-gold-image-cli-and-console.md)

Quick image id lookup:

```bash
IMAGE_ID=$(az image show -g fl-gold-rg -n fl-rhel-gold --query id -o tsv)
```

NSG must allow **TCP 2222** and **TCP 35443** (reuse `fl-rhel-gold-poc-nsg` or create a new NSG).

**Never** commit Azure credentials.
