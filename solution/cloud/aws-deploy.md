# Deploy gold image on AWS (Blank OPEN)

## Goal

Import the manually built disk as an **AMI**, launch a VM, open **2222** and **35443**, prove Expansion Pack checks.

## High-level steps

1. Compose with local Image Builder (`docs/poc-steps-image-builder.md`):  
   ```bash
   sudo ./scripts/compose.sh ami
   ```  
   Or convert a `qcow2` smoke-test disk to **raw** if needed:  
   ```bash
   qemu-img convert -f qcow2 -O raw fl-rhel-gold.qcow2 fl-rhel-gold.raw
   ```  
2. In RHDP **AWS Blank OPEN**:  
   - Upload AMI/raw to S3 (or use `image-builder` AWS upload flags if credentials allow)  
   - Create snapshot / import as AMI (follow OPEN lab import docs for your env)  
   - Name AMI `fl-rhel-gold`  
3. Launch instance (t3.small+).  
4. Security group inbound:  
   - TCP **2222** from your IP `/32`  
   - TCP **35443** from your IP `/32`  
5. Connect:  
   ```bash
   ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<PUBLIC_IP>
   ```  
6. Prove:  
   ```bash
   curl -s http://127.0.0.1:35443/
   sudo bash verify-gold-image.sh
   sudo reboot
   ```  
7. Terminate instance and delete OPEN env when done.  

**Never** commit AWS keys or RHDP passwords.
