# Where, when, and why — solution commands

Use this to know **where** to run each command (Mac vs builder vs PoC VM), **when** in the flow, and **why** it exists.

```text
Mac Terminal          →  drives AWS/Azure APIs + scripts
Builder VM (RHEL)     →  Image Builder compose only (rhc + compose)
PoC / gold VM         →  prove Expansion Pack (SSH 2222, curl 35443)
AWS/Azure Console     →  optional launch without scripts (+ User data)
```

---

## 1. One-time setup (Mac)

| Command / action | Where | When | Why |
|---|---|---|---|
| Order AWS/Azure Blank OPEN | browser (demo.redhat.com) | Before any compose/launch | Lab credentials + quota |
| `cp env.example env.local` + fill secrets | Mac: `solution/cloud/aws` or `azure` | Once per OPEN | Scripts/CLI need keys; **never commit** `env.local` |
| `export PATH=…/.tools/aws-cli:$PATH` | Mac | Each new terminal (AWS) | Use vendored AWS CLI if system `aws` missing |
| `az login` / `az account set` | Mac | Each Azure session | Authenticate Azure CLI |
| `chmod +x *.sh` | Mac: aws/ or azure/ | Once after clone | Scripts must be executable |

---

## 2. Build the gold image (Image Builder)

| Command / action | Where | When | Why |
|---|---|---|---|
| `./compose-on-builder.sh` | **Mac** | Create gold **AMI** | Launches builder EC2, runs Image Builder, registers AMI |
| `./compose-vhd-on-azure-builder.sh` | **Mac** | Create gold **VHD** (Azure) | Launches Azure RHEL builder, composes VHD, uploads page blob |
| `ssh … ec2-user@` / `azureuser@` + `sudo rhc connect` | **Builder VM** | When compose says “not RHSM-subscribed” | Image Builder needs Red Hat subscription (Marketplace RHUI ≠ RHSM) |
| `./compose-… --continue <IP>` / `continue-compose-on-builder.sh` | **Mac** | After `rhc connect`, or resume | Reuse same builder; don’t launch a duplicate |
| `./setup-vmimport-role.sh` | **Mac** | Once per AWS account if AMI register fails | IAM role `vmimport` required for AMI import |
| `./upload-vhd-from-azure-builder.sh <IP>` | **Mac** | Compose OK but “no .vhd” / azcopy failed | VHD already on builder; only upload missing |
| `./create-image.sh` | **Mac** (Azure) | After VHD is in storage | Turns page blob into Azure **managed image** |

**Why a builder at all?** Image Builder must run on **subscribed RHEL**, not on your Mac. The builder is temporary factory capacity.

---

## 3. Launch a VM from the gold image

### A) With project scripts (recommended)

| Command | Where | When | Why |
|---|---|---|---|
| `./launch-gold-ami.sh` | Mac (aws/) | Gold AMI exists | `run-instances --image-id $GOLD_AMI_ID` + cloud-init firstboot (httpd) |
| `./launch-vm.sh` | Mac (azure/) | Gold managed image exists | Creates Azure VM from image + NSG 2222/35443 + custom-data |

### B) Without scripts (CLI / Console)

| Action | Where | When | Why |
|---|---|---|---|
| Resolve `AMI_ID` / `IMAGE_ID` | Mac CLI | Before launch | Same as “which gold image?” |
| SG / NSG rules for **2222** + **35443** (My IP) | Console or CLI | Before/at launch | Network allow; **does not** start httpd |
| **User data** (AWS Advanced details) — see below | AWS Console | At launch | Runs firstboot so **httpd starts** |
| `aws ec2 run-instances --image-id …` / `az vm create --image …` | Mac CLI | Gold image ready | Spin VM without repo scripts |

**AWS Console User data** (paste in Advanced details):

```yaml
#cloud-config
runcmd:
  - [rm, -f, /var/lib/fl-gold-firstboot-done]
  - [/bin/bash, /etc/fl-gold/bin/fl-gold-firstboot.sh]
```

| Piece | Why |
|---|---|
| `rm … firstboot-done` | Marker would skip firstboot; remove so it runs on this new VM |
| `fl-gold-firstboot.sh` | Starts Podman httpd on **35443**, SELinux ports, `/tmp` noexec tweaks |

**SG alone is not enough:** SG opens the port; firstboot/user-data starts the process.

Full CLI/console copy-paste: [launch-gold-image-cli-and-console.md](./launch-gold-image-cli-and-console.md) · [aws/README.md](../solution/cloud/aws/README.md) · [azure/README.md](../solution/cloud/azure/README.md)

---

## 4. Prove Expansion Pack (PoC / gold VM)

| Command | Where | When | Why |
|---|---|---|---|
| `ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<IP>` | Mac → **PoC VM** | After launch (~4–5 min) | Gold image uses **fladmin1** and port **2222** (not `ec2-user`/22) |
| `getenforce` / `findmnt` / `ss` / `curl :35443` | **On PoC VM** | After SSH | Live Expansion Pack evidence |
| `./verify-remote.sh` | **Mac** | After launch | Automated checks from laptop |
| `aws ec2 reboot-instances` / `az vm restart` | Mac | After first PASS | Prove survives reboot |
| `./verify-remote.sh` again | Mac | After reboot | Confirm services still up |

**If SSH times out:** your public IP changed — add **My IP** to SG/NSG for 2222 (and 35443). Not a gold-image failure.

**If mounts look empty:** use one mount per command:

```bash
for m in /var/log /home /tmp /var/tmp; do findmnt "$m"; done
```

---

## 5. Cleanup (stop billing)

| Command | Where | When | Why |
|---|---|---|---|
| `./terminate-ec2.sh` | Mac (aws/) | Done with PoC | Terminate PoC instance |
| `aws ec2 terminate-instances --instance-ids …` | Mac | Done with builders | Builders are large/expensive |
| `./cleanup.sh` / `./cleanup.sh --group` | Mac (azure/) | Done with Azure PoC | Delete VM or whole RG |
| Delete RHDP OPEN | browser | Fully finished | Lab account teardown |

---

## 6. Flow cheat sheet

```text
WHEN you want a gold AMI/VHD
  WHERE Mac → compose-*-builder.sh
  WHERE Builder → rhc connect (if asked)
  WHY  Image Builder must run on subscribed RHEL

WHEN you want a gold VM
  WHERE Mac → launch-gold-ami.sh / launch-vm.sh
     OR Console/CLI + User data (AWS) / custom-data (Azure)
  WHY  Clone gold image; firstboot starts httpd

WHEN you want proof
  WHERE Mac → verify-remote.sh ; PoC VM → getenforce/findmnt/curl
  WHY  Expansion Pack checklist + reboot
```

---

## Related

- [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)  
- [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md)  
- [demo-commands-gold-image.md](./demo-commands-gold-image.md)  
