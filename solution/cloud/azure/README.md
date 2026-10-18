# Azure PoC — Expansion Pack gold VHD (RHDP Blank OPEN)

Prove the same Image Builder gold image on **Azure** using a **VHD** → managed image → VM.

## Flow

```text
1. Compose VHD (RHEL Image Builder on AWS builder EC2)
       ./../aws/compose-vhd-on-builder.sh
       → s3://…/gold/*.vhd

2. Azure Blank OPEN + az login
       ./upload-vhd.sh → ./create-image.sh → ./launch-vm.sh → ./verify-remote.sh
```

Full runbook: [`docs/azure-gold-vhd-poc-runbook.md`](../../../docs/azure-gold-vhd-poc-runbook.md)

## Prerequisites

1. Order **Azure Blank OPEN** at [demo.redhat.com](https://demo.redhat.com)  
2. Install Azure CLI: `brew install azure-cli`  
3. Gold VHD composed (or still on S3 from step 1)  
4. Copy env:

```bash
cd solution/cloud/azure
cp env.example env.local
# fill AZURE_SUBSCRIPTION_ID (+ tenant / SP if needed)
```

## Quick commands

```bash
chmod +x *.sh
./upload-vhd.sh /path/to/gold.vhd   # or omit path to pull from aws/output/gold-vhd.json
./create-image.sh
./launch-vm.sh
# wait 4–5 minutes
./verify-remote.sh
./cleanup.sh                        # or ./cleanup.sh --group
```

## Security

- Never commit `env.local`, `.pem`, or OPEN credentials  
- NSG opens **2222** + **35443** from your IP only  
- Delete the RHDP OPEN when finished  
