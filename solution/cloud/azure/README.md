# Azure — Expansion Pack gold VHD (proven)

RHDP **Azure Blank OPEN** → local Image Builder → **`.vhd`** → managed image → PoC VM.

**Full steps:** [`docs/azure-gold-vhd-poc-runbook.md`](../../../docs/azure-gold-vhd-poc-runbook.md)

## Quick path

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

## Security

- Never commit `env.local` or keys  
- NSG: builder **22**; PoC **2222** + **35443** from your IP  
- Delete the RHDP OPEN when finished  
