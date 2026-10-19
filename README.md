# Fedora Lane — Server/Cloud OS TDP  
## Junior Consultant · Expansion Pack gold image

**Branch:** [`expansion-tdp-solution`](https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution)  
**Repo:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster  

**What this is:** A **repeatable RHEL gold image** for Fedora Lane’s e-commerce web tier, built with **local RHEL Image Builder** (not hosted console.redhat.com), proven on **AWS (AMI)** and **Azure (VHD)**.

Upstream: [Composing a customized RHEL system image](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

> Never commit RHDP / cloud credentials (`env.local`, `.pem`, keys). Prefer a private remotes; add reviewers as required by your cohort.

---

## Customer challenges → this solution

| Fedora Lane challenge | How we address it |
|---|---|
| Inconsistent estate (~1,600 servers) | One blueprint → repeatable `ami` / `vhd` |
| Untraceable / risky change | Hardened SSH/sudo baked in; blueprint versioned in Git |
| Container skills gap | httpd runs as a **container** on the gold image (port 35443) |

---

## What’s in the repo

| Path | Purpose |
|---|---|
| [`solution/image-builder/`](./solution/image-builder/) | **Primary factory** — blueprint, firstboot, compose scripts |
| [`solution/cloud/aws/`](./solution/cloud/aws/) | AWS Blank OPEN — compose AMI, launch, verify |
| [`solution/cloud/azure/`](./solution/cloud/azure/) | Azure Blank OPEN — compose VHD, image, launch, verify |
| [`solution/kickstart/`](./solution/kickstart/) | Alternate factory A |
| [`solution/image-mode/`](./solution/image-mode/) | Alternate factory B (bootc) |
| [`docs/`](./docs/) | Overview, runbooks, presentation scripts, checklist |

---

## Proven PoC status

| Cloud | Artifact | Runbook | Status |
|---|---|---|---|
| **AWS** | Gold **AMI** | [`docs/aws-gold-ami-poc-runbook.md`](./docs/aws-gold-ami-poc-runbook.md) | Proven (verify + reboot) |
| **Azure** | Gold **VHD** → managed image | [`docs/azure-gold-vhd-poc-runbook.md`](./docs/azure-gold-vhd-poc-runbook.md) | Proven (verify + reboot) |

Shared Expansion Pack controls (both paths):

- Separate `/var/log`, `/home`, `/tmp`, `/var/tmp` (&lt; 5 GiB); `/tmp` **noexec**  
- SELinux **enforcing**  
- SSH **2222** (key-only, no root)  
- httpd **container** on **35443**  
- `fladmins` + firewall limited to those ports  
- Survives **reboot**  

---

## How to run (quick)

### A) Azure gold image (pure Azure — recommended for demo)

Full steps: [`docs/azure-gold-vhd-poc-runbook.md`](./docs/azure-gold-vhd-poc-runbook.md)

```bash
git checkout expansion-tdp-solution
cd solution/cloud/azure
cp -n env.example env.local   # set AZURE_SUBSCRIPTION_ID from Azure Blank OPEN
az login && chmod +x *.sh

./compose-vhd-on-azure-builder.sh
# ssh azureuser@<IP> && sudo rhc connect && exit
# ./compose-vhd-on-azure-builder.sh --continue <IP>

./create-image.sh && ./launch-vm.sh
./verify-remote.sh
# optional: az vm restart ... && ./verify-remote.sh
./cleanup.sh
```

### B) AWS gold AMI

Full steps: [`docs/aws-gold-ami-poc-runbook.md`](./docs/aws-gold-ami-poc-runbook.md)

```bash
cd solution/cloud/aws
cp -n env.example env.local   # RHDP AWS Blank OPEN keys
export PATH="$PWD/../../.tools/aws-cli:$PATH"   # if using vendored CLI
./compose-on-builder.sh       # or continue / reupload helpers
./launch-gold-ami.sh && ./verify-remote.sh
./terminate-ec2.sh
```

### C) Blueprint only (any subscribed RHEL builder)

```bash
cd solution/image-builder
sudo ./scripts/install-image-builder.sh
./scripts/generate-blueprint.sh   # set real SSH public keys in TOML
sudo ./scripts/compose.sh ami     # or: vhd
```

---

## Documentation (client-facing)

| Doc | Path |
|---|---|
| Solution overview | [`docs/solution-overview.md`](./docs/solution-overview.md) |
| PoC index | [`docs/poc-steps.md`](./docs/poc-steps.md) |
| Verification checklist | [`docs/verification-checklist.md`](./docs/verification-checklist.md) |
| Part 1 video script (~15 min) | [`docs/presentation-script-part1-video.md`](./docs/presentation-script-part1-video.md) |
| Demo commands (compose → gold VM) | [`docs/demo-commands-gold-image.md`](./docs/demo-commands-gold-image.md) |
| Launch gold image (CLI + Console, no scripts) | [`docs/launch-gold-image-cli-and-console.md`](./docs/launch-gold-image-cli-and-console.md) |
| Where / when / why to run commands | [`docs/where-when-why-commands.md`](./docs/where-when-why-commands.md) |
| Part 2 live script | [`docs/presentation-script-part2-live.md`](./docs/presentation-script-part2-live.md) |
| **Customer presentation (Google Doc ready)** | [`docs/customer-presentation-fedora-lane.md`](./docs/customer-presentation-fedora-lane.md) |
| Slide outline | [`docs/presentation-slides.md`](./docs/presentation-slides.md) |
| Part 1 submission guide | [`docs/part1-submission-guide.md`](./docs/part1-submission-guide.md) |

---

## Demo tip (Part 1 video / Part 2 live)

1. Open blueprint `solution/image-builder/fl-rhel-gold.toml` in Git.  
2. Show a running PoC VM (AWS or Azure): SSH `:2222`, `getenforce`, `findmnt`, `curl :35443`.  
3. Show `./verify-remote.sh` PASS (and mention reboot).  
4. Close with pilot recommendation + Git as source of truth.  
