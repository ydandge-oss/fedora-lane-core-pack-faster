# Deploy gold image on Azure (Blank OPEN)

## Goal

Import the manually built disk as a **VHD / managed image**, create a VM, open **2222** and **35443**, prove checks.

## High-level steps

1. Compose with local Image Builder (`docs/poc-steps-image-builder.md`):  
   ```bash
   sudo ./scripts/compose.sh vhd
   ```  
   Or convert a `qcow2` smoke-test disk if needed:  
   ```bash
   qemu-img convert -f qcow2 -O vpc fl-rhel-gold.qcow2 fl-rhel-gold.vhd
   # ensure fixed-size VHD as required by Azure docs
   ```  
2. In RHDP **Azure Blank OPEN**:  
   - Upload VHD to storage account  
   - Create image / gallery image  
   - Create VM from image  
3. NSG rules: allow **2222** and **35443** from your IP.  
4. SSH `-p 2222` as `fladmin1`.  
5. Run `verify-gold-image.sh` and `curl :35443`.  
6. Reboot and re-verify.  
7. Delete resources / OPEN env when finished.  

**Never** commit Azure credentials.
