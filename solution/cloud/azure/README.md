# Azure — Expansion Pack gold VHD (proven)

RHDP **Azure Blank OPEN** → local Image Builder → **`.vhd`** → managed image → PoC VM.

**Full steps:** [`docs/azure-gold-vhd-poc-runbook.md`](../../../docs/azure-gold-vhd-poc-runbook.md)

## Quick path (project scripts)

```bash
cd solution/cloud/azure
cp -n env.example env.local   # AZURE_SUBSCRIPTION_ID, AZURE_LOCATION
az login
chmod +x *.sh

./compose-vhd-on-azure-builder.sh
# if prompted: ssh + sudo rhc connect, then --continue <IP>

# if compose OK but upload missed:
# ./upload-vhd-from-azure-builder.sh <BUILDER_IP>

./create-image.sh
./launch-vm.sh
./verify-remote.sh
az vm restart -g fl-gold-rg -n fl-rhel-gold-poc
./verify-remote.sh
./cleanup.sh
```

---

## Launch from gold image **without** project scripts

Use when the managed image (e.g. `fl-rhel-gold`) already exists and the customer prefers raw **Azure CLI** or the **Portal**.  
Gold VMs use **SSH 2222** and **httpd 35443** (not port 22).

**NSG** = Network Security Group (Azure firewall). The PoC script often created `fl-rhel-gold-poc-nsg`; reuse it or create a new one.

Shared reference: [`docs/launch-gold-image-cli-and-console.md`](../../../docs/launch-gold-image-cli-and-console.md)

### Azure CLI (resolve image id + launch)

```bash
az login
az account set --subscription "<subscription-id>"

RG=fl-gold-rg
LOCATION=eastus
IMAGE_NAME=fl-rhel-gold
VM_NAME=fl-rhel-gold-vm

# Gold image id (same idea as AMI_ID on AWS)
IMAGE_ID=$(az image show -g "$RG" -n "$IMAGE_NAME" --query id -o tsv)
echo "IMAGE_ID=$IMAGE_ID"

# Option A — reuse PoC NSG if it still exists:
# NSG=fl-rhel-gold-poc-nsg

# Option B — create a new NSG with Expansion Pack ports
NSG=${VM_NAME}-nsg
MYIP=$(curl -4 -fsS ifconfig.me)/32
az network nsg create -g "$RG" -n "$NSG" -l "$LOCATION" 2>/dev/null || true
az network nsg rule create -g "$RG" --nsg-name "$NSG" \
  -n AllowSSH2222 --priority 1000 --access Allow --protocol Tcp \
  --destination-port-ranges 2222 --source-address-prefixes "$MYIP" 2>/dev/null || true
az network nsg rule create -g "$RG" --nsg-name "$NSG" \
  -n AllowHttpd35443 --priority 1010 --access Allow --protocol Tcp \
  --destination-port-ranges 35443 --source-address-prefixes "$MYIP" 2>/dev/null || true

# Public key for --ssh-key-values (derive from private key if needed)
# ssh-keygen -y -f ~/.ssh/fl-gold-poc.pem > ~/.ssh/fl-gold-poc.pem.pub

az vm create \
  -g "$RG" \
  -n "$VM_NAME" \
  --image "$IMAGE_ID" \
  --size Standard_B2s \
  --admin-username fladmin1 \
  --ssh-key-values ~/.ssh/fl-gold-poc.pem.pub \
  --nsg "$NSG" \
  --public-ip-sku Standard \
  --os-disk-size-gb 40

PUBLIC_IP=$(az vm show -d -g "$RG" -n "$VM_NAME" --query publicIps -o tsv)
echo "PUBLIC_IP=$PUBLIC_IP"

# After ~3–5 minutes:
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$PUBLIC_IP
curl -s "http://${PUBLIC_IP}:35443/"
```

List NSGs: `az network nsg list -g fl-gold-rg -o table`

### Azure Portal

1. **Create a resource** → **Virtual machine**.  
2. Image: **See all images** → **My images** → select **fl-rhel-gold** (not Marketplace RHEL).  
3. Size e.g. Standard_B2s; admin user `fladmin1` + SSH public key.  
4. Networking / NSG: allow inbound **TCP 2222** and **TCP 35443** from your IP.  
5. OS disk ≥ 40 GiB → **Create**.  
6. Connect: `ssh -i key.pem -p 2222 fladmin1@<public-ip>`  
7. Test: `http://<public-ip>:35443/`

---

## Security

- Never commit `env.local` or keys  
- NSG: builder **22**; PoC **2222** + **35443** from your IP  
- Delete the RHDP OPEN when finished  
