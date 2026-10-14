# Deploy gold image on AWS (Blank OPEN)

## Goal

Import the manually built disk as an **AMI**, launch a VM, open **2222** and **35443**, prove Expansion Pack checks.

## High-level steps

1. Build & seal gold VM (`docs/poc-steps.md` Phase A).  
2. Convert disk to **raw**:  
   ```bash
   qemu-img convert -f qcow2 -O raw fl-rhel-gold.qcow2 fl-rhel-gold.raw
   ```  
3. In RHDP **AWS Blank OPEN**:  
   - Upload raw to S3  
   - Create snapshot / import as AMI (follow OPEN lab import docs for your env)  
   - Name AMI `fl-rhel-gold`  
4. Launch instance (t3.small+).  
5. Security group inbound:  
   - TCP **2222** from your IP `/32`  
   - TCP **35443** from your IP `/32`  
6. Connect:  
   ```bash
   ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<PUBLIC_IP>
   ```  
7. Prove:  
   ```bash
   curl -s http://127.0.0.1:35443/
   sudo bash verify-gold-image.sh
   sudo reboot
   ```  
8. Terminate instance and delete OPEN env when done.  

**Never** commit AWS keys or RHDP passwords.
