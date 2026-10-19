# Fedora Lane — Server/Cloud OS Expansion Pack  
## Technical solution presentation (customer-ready)

**Copy into Google Docs:** File → New → Document → paste this entire file (or File → Open → Upload the `.md`).  
**Audience:** Alex Lee (Infrastructure), Casey Novak (Linux), Ren Tanaka (Security), Cameron Shaw (App Dev), Anya Sharma (CIO)  
**Duration:** ~15 minutes  
**Git source of truth:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution  

---

# Slide 1 — Title

**Fedora Lane Expansion Pack**  
Secure, standardized **RHEL gold image** for the e-commerce web fleet  

Built with **local RHEL Image Builder** (not hosted console.redhat.com)  
Proven on **AWS (AMI)** and **Azure (VHD)**  

*Junior Consultant · FASTER Server/Cloud OS TDP*

---

# Slide 2 — Agenda

1. Your challenges (confirm understanding)  
2. What we built  
3. How it works (blueprint → gold image → VM)  
4. Security & Expansion Pack controls  
5. Live evidence / how you operate it  
6. Scaling to ~1,600 servers  
7. Recommendations & next phase  

---

# Slide 3 — Challenges we heard

| Challenge | What it means for Fedora Lane |
|---|---|
| **Inconsistent estate** | ~1,600 servers; Rocky, Ubuntu, CentOS Stream, Amazon Linux — no single web baseline |
| **Risky / untraceable change** | Long outages when drift and ad-hoc changes collide |
| **Container skills gap** | Ops need a clear, repeatable way to run services in containers on RHEL |

**Want:** One secure RHEL baseline for **AWS and Azure** web nodes, rebuildable from Git, Expansion Pack hardened.

---

# Slide 4 — Solution in one sentence

> We deliver a **gold RHEL image** from a **versioned Image Builder blueprint** in Git.  
> Compose once to **AMI** (AWS) and **VHD** (Azure), then **launch VMs from that image** — same controls every time.

**Not** hosted Image Builder at console.redhat.com — **local** Image Builder on a subscribed RHEL builder, per Red Hat’s compose procedure.

---

# Slide 5 — Architecture

```text
                    Expansion Pack controls
              (partitions, SELinux, SSH 2222, httpd 35443,
               fladmins, firewall, containerized httpd)
                              │
                              ▼
                 Blueprint in Git (fl-rhel-gold.toml)
                              │
                              ▼
              Local RHEL Image Builder (compose)
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
        AWS gold AMI                    Azure gold VHD
        (managed image)                 → managed image
              │                               │
              └───────────────┬───────────────┘
                              ▼
                    Gold VM (web node)
                    verify + reboot proven
```

---

# Slide 6 — How you get from blueprint to running VM

| Step | What happens | Who runs it |
|---|---|---|
| 1. Blueprint | Recipe: mounts, users, ports, packages | Git / Linux team |
| 2. Compose | Image Builder builds **AMI** or **VHD** | Builder VM (RHSM subscribed) |
| 3. Register | AMI in AWS / managed image in Azure | Cloud automation or CLI |
| 4. Launch | New VM **from gold image** (not stock Marketplace) | Console, CLI, or scripts |
| 5. Firstboot | Starts httpd container on **35443** (cloud-init / User data) | Automatic at launch |
| 6. Verify | SELinux, mounts, ports, curl, reboot | Ops / our verify scripts |

**Important:** Security Group / NSG **opens** ports 2222 and 35443.  
**Firstboot / User data** **starts** httpd — both are required.

---

# Slide 7 — Expansion Pack controls (baked into the image)

| Control | Implementation |
|---|---|
| Separate filesystems | `/var/log`, `/home`, `/tmp`, `/var/tmp` (size-capped) |
| `/tmp` noexec | Mount options |
| SELinux | Enforcing |
| SSH | Port **2222**, key-only, **no root** SSH |
| Admins | Group `fladmins`, users `fladmin1` / `fladmin2` |
| Web | **httpd in a container** on port **35443** |
| Firewall | Only SSH + httpd ports |
| Proven | AWS AMI + Azure VHD, including **after reboot** |

---

# Slide 8 — Operating without our scripts (customer-friendly)

You can use **native AWS/Azure CLI or Console**.

**AWS**

1. Region **us-east-2** (Ohio) — where the gold AMI lives  
2. EC2 → AMIs → **fl-rhel-gold** → Launch  
3. SG: TCP **2222** + **35443** from admin IP  
4. Advanced → **User data** (so httpd starts):

```yaml
#cloud-config
runcmd:
  - [rm, -f, /var/lib/fl-gold-firstboot-done]
  - [/bin/bash, /etc/fl-gold/bin/fl-gold-firstboot.sh]
```

5. SSH: `ssh -i <key> -p 2222 fladmin1@<ip>`  
6. Test: `curl http://<ip>:35443/`

**Azure**

1. Create VM from managed image **fl-rhel-gold** (My images)  
2. NSG: TCP **2222** + **35443**  
3. SSH `fladmin1` on port **2222**  
4. Same verify checks  

Full detail: repo docs `launch-gold-image-cli-and-console.md` and `where-when-why-commands.md`.

---

# Slide 9 — Live evidence (demo talking points)

On a gold VM we show:

- `getenforce` → Enforcing  
- Separate mounts for `/var/log`, `/home`, `/tmp`, `/var/tmp`  
- `/tmp` options include **noexec**  
- Listeners on **2222** and **35443**  
- Fedora Lane index page from the httpd container  
- `fladmins` / `fladmin1` present  
- Root SSH rejected; password SSH rejected  
- Survives **reboot**  

Same checklist passed on **AWS** and **Azure**.

---

# Slide 10 — Scaling toward ~1,600 servers

We do **not** run Image Builder 1,600 times.

1. **Freeze** a versioned gold AMI / Azure image  
2. **Launch** web nodes from that image (Launch Template / ASG on AWS; VM Scale Sets / Gallery on Azure)  
3. **Replace in waves** (canary → batches → rest) — cut traffic over, then retire old VMs  
4. **Day-2:** change blueprint in Git → recompose new gold version → roll new waves  

In-place “reimage root” is not the primary cloud model; **replace from gold image** is safer and fits AWS/Azure automation.

---

# Slide 11 — Value mapped to your challenges

| Your challenge | Our deliverable |
|---|---|
| Inconsistency | One blueprint → repeatable AMI/VHD → identical web baselines |
| Untraceable / risky change | Hardened SSH/sudo baked in; rebuild from Git anytime |
| Container skills gap | httpd runs as a **container** on every gold VM (port 35443) |
| Dual cloud | Proven path on **AWS and Azure** |

---

# Slide 12 — Recommendations & next phase

**This month**

1. Pilot gold image on **non-prod** web nodes (AWS and/or Azure)  
2. Adopt Launch Template / scale set pattern for new capacity  
3. Keep Git blueprint as the change-control source of truth  

**Next**

- Wave replace selected prod web pools  
- Optional: OpenSCAP CIS profile on the same factory  
- Kickstart / Image Mode remain available as alternate factories in the same repo if preferred  

**Ask:** Approve non-prod pilot using the Image Builder gold image as the web OS standard.

---

# Slide 13 — Close / Q&A

**Repository:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution  

**Key docs**

| Doc | Purpose |
|---|---|
| `README.md` | How to set up and run |
| `docs/solution-overview.md` | Architecture & challenges |
| `docs/aws-gold-ami-poc-runbook.md` | AWS proven path |
| `docs/azure-gold-vhd-poc-runbook.md` | Azure proven path |
| `docs/launch-gold-image-cli-and-console.md` | Console/CLI without scripts |
| `docs/where-when-why-commands.md` | Where / when / why for each command |
| `docs/verification-checklist.md` | Expansion Pack checklist |

Thank you — questions welcome.

---

## How to turn this into a Google Doc

1. Open [Google Docs](https://docs.google.com) → **Blank document**.  
2. Title: `Fedora Lane — Expansion Pack Gold Image — Technical Solution`.  
3. Paste from this file (or upload the `.md` via File → Open → Upload).  
4. Apply **Heading 1** to each `# Slide N` line; optional: Insert → Break → Section for page-per-slide.  
5. Share with stakeholders (Viewer) and attach the GitHub branch link in the Doc description or first page.  

## Speaker notes

Use [`presentation-script-part1-video.md`](./presentation-script-part1-video.md) as the spoken script alongside these slides.  
