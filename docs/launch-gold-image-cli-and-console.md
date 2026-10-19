# Launch a VM from the gold image — CLI + Console (no project scripts)

For operators who already have a **gold AMI** (AWS) or **gold managed image** (Azure).  
Gold VMs listen on **SSH 2222** and **httpd 35443** (not 22 / 80).

---

## AWS — from gold AMI

### A) AWS CLI (no repo scripts)

**1. Find the gold AMI**

```bash
export AWS_REGION=us-east-2   # your region
aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold \
  --query 'Images[].{ImageId:ImageId,Name:Name,State:State}' \
  --output table
```

Note `ImageId` → e.g. `ami-0abc123...`

**2. Security group — allow Expansion Pack ports from your IP**

```bash
MYIP=$(curl -4 -fsS ifconfig.me)/32
SG_ID=sg-xxxxxxxx          # your SG
VPC_ID=vpc-xxxxxxxx

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --ip-permissions \
  "IpProtocol=tcp,FromPort=2222,ToPort=2222,IpRanges=[{CidrIp=$MYIP,Description=SSH-gold}]" \
  "IpProtocol=tcp,FromPort=35443,ToPort=35443,IpRanges=[{CidrIp=$MYIP,Description=httpd-gold}]"
```

(Ignore “already exists” errors if rules are present.)

**3. Launch one instance from the gold AMI**

```bash
AMI_ID=ami-0abc123...
KEY_NAME=my-keypair          # EC2 key pair name in this account
SUBNET_ID=subnet-xxxxxxxx
SG_ID=sg-xxxxxxxx

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t3.medium \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":40,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=fl-rhel-gold-vm}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance: $INSTANCE_ID"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "Public IP: $PUBLIC_IP"
```

**4. Connect / test (after ~3–5 minutes)**

```bash
ssh -i /path/to/key.pem -p 2222 fladmin1@$PUBLIC_IP
curl -s "http://${PUBLIC_IP}:35443/"
```

Optional user-data (cloud-init) can be passed with `--user-data file://cloud-init.yaml` if you need first-boot tweaks; the gold AMI already contains Expansion Pack baselines.

---

### B) AWS Console steps

1. Open **EC2** → **AMIs** (Owned by me) → select **fl-rhel-gold** (or your AMI name) → **Launch instance from AMI**.  
2. **Name:** e.g. `fl-rhel-gold-vm`.  
3. **Instance type:** e.g. `t3.medium`.  
4. **Key pair:** choose an existing key (or create one and download `.pem`).  
5. **Network:** VPC + subnet with public IP if you need SSH from internet.  
6. **Firewall (security group):**  
   - Inbound **TCP 2222** from your IP (SSH)  
   - Inbound **TCP 35443** from your IP (httpd)  
   - Do **not** rely on port 22 — gold image uses **2222**.  
7. **Storage:** ≥ 40 GiB gp3 root.  
8. **Launch instance**.  
9. Wait until **Running** + status checks OK.  
10. Connect: `ssh -i key.pem -p 2222 fladmin1@<Public-IP>`  
11. Browser/curl: `http://<Public-IP>:35443/`

---

## Azure — from gold managed image

Assumes you already created a managed image (e.g. `fl-rhel-gold`) from the Image Builder VHD.

### A) Azure CLI (no repo scripts)

**1. Login and set subscription**

```bash
az login
az account set --subscription "<subscription-id>"
RG=fl-gold-rg                 # resource group that holds the image
LOCATION=eastus
IMAGE_NAME=fl-rhel-gold
VM_NAME=fl-rhel-gold-vm
```

**2. Confirm the gold image**

```bash
az image show -g "$RG" -n "$IMAGE_NAME" --query '{name:name,id:id,os:storageProfile.osDisk.osType}' -o table
IMAGE_ID=$(az image show -g "$RG" -n "$IMAGE_NAME" --query id -o tsv)
```

**3. NSG for ports 2222 and 35443**

```bash
MYIP=$(curl -4 -fsS ifconfig.me)/32
NSG=${VM_NAME}-nsg

az network nsg create -g "$RG" -n "$NSG" -l "$LOCATION"
az network nsg rule create -g "$RG" --nsg-name "$NSG" \
  -n AllowSSH2222 --priority 1000 --access Allow --protocol Tcp \
  --destination-port-ranges 2222 --source-address-prefixes "$MYIP"
az network nsg rule create -g "$RG" --nsg-name "$NSG" \
  -n AllowHttpd35443 --priority 1010 --access Allow --protocol Tcp \
  --destination-port-ranges 35443 --source-address-prefixes "$MYIP"
```

**4. Create VM from the gold image**

```bash
# Use an SSH public key the gold image trusts (same key baked in blueprint / used at PoC)
az vm create \
  -g "$RG" \
  -n "$VM_NAME" \
  --image "$IMAGE_ID" \
  --size Standard_B2s \
  --admin-username fladmin1 \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --nsg "$NSG" \
  --public-ip-sku Standard \
  --os-disk-size-gb 40

PUBLIC_IP=$(az vm show -d -g "$RG" -n "$VM_NAME" --query publicIps -o tsv)
echo "Public IP: $PUBLIC_IP"
```

**5. Connect / test (after ~3–5 minutes)**

```bash
ssh -i ~/.ssh/id_rsa -p 2222 fladmin1@$PUBLIC_IP
curl -s "http://${PUBLIC_IP}:35443/"
```

---

### B) Azure Portal steps

1. **Create a resource** → **Virtual machine**.  
2. **Subscription / Resource group:** same RG as the gold image (or one that can use it).  
3. **Image:** **See all images** → **My Items** / **Shared** → select managed image **fl-rhel-gold** (do **not** pick a Marketplace RHEL stock image).  
4. **Size:** e.g. Standard_B2s.  
5. **Administrator account:** SSH public key; username `fladmin1` (or a user present on the gold image).  
6. **Inbound ports:** set to **None** in the wizard if you will attach a custom NSG; then add NSG rules:  
   - TCP **2222** (SSH)  
   - TCP **35443** (httpd)  
   from your client IP.  
7. Disks: OS disk ≥ 40 GiB.  
8. **Review + create** → **Create**.  
9. After Running: **Connect** with SSH on port **2222**.  
10. Test: `http://<public-ip>:35443/`

---

## Checklist (both clouds)

| Check | Command / UI |
|---|---|
| Image is **your** gold image | AMI name / Azure managed image — not stock Marketplace |
| SSH port | **2222** |
| Web port | **35443** |
| User | `fladmin1` (key must match blueprint) |
| SELinux / mounts | `getenforce`; `findmnt /tmp` (expect `noexec`) |

---

## Related

- Build gold AMI: [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)  
- Build gold Azure image: [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md)  
- Repo automation (optional): `solution/cloud/aws/launch-gold-ami.sh`, `solution/cloud/azure/launch-vm.sh`  
