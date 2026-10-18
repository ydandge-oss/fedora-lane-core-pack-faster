# Deploy gold image on Azure (Blank OPEN)

**Full runbook:** [`docs/azure-gold-vhd-poc-runbook.md`](../../docs/azure-gold-vhd-poc-runbook.md)  
**Scripts:** [`solution/cloud/azure/`](./azure/)

## Goal

Import the Image Builder **VHD** as a managed image, create a VM, open **2222** and **35443**, prove Expansion Pack checks.

## Steps (short)

1. **Compose VHD** (on AWS builder EC2 — same Image Builder as AMI):

   ```bash
   cd solution/cloud/aws
   ./compose-vhd-on-builder.sh
   ```

2. **Azure Blank OPEN** + `az login`; configure `solution/cloud/azure/env.local`.

3. **Import + PoC:**

   ```bash
   cd solution/cloud/azure
   ./upload-vhd.sh
   ./create-image.sh
   ./launch-vm.sh
   ./verify-remote.sh
   ```

4. Reboot with `az vm restart`, re-verify, then `./cleanup.sh`.

**Never** commit Azure credentials.
