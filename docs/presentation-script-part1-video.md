# Part 1 practice video — ~15 minutes  
## Server/Cloud OS TDP · Expansion Pack gold image

**Audience:** Casey Novak / Alex Lee (practice via RHSH)  
**Record:** RHSH practice activity → submit recording link + deliverable links on the Google form  
**Topic on form:** Server/Cloud OS TDP  

Use this script as a teleprompter. Keep Git open + one live PoC VM (Azure or AWS).  
**Cheat sheet of commands:** [`demo-commands-gold-image.md`](./demo-commands-gold-image.md)

---

## Timing map (required structure)

| Segment | Time | What you do |
|---|---|---|
| Opening | 1–2 min | Team + restated challenges |
| Live walkthrough | 5–10 min | **Commands → gold image → VM** + prove on the VM |
| Value summary | 2–5 min | Map solution → challenges |
| Closing | 1–2 min | Next-phase recommendations |
| **Total** | **~15 min** | |

---

## 1. Opening (1–2 min)

“Hi, I’m [Name], Junior Consultant on the FASTER Server/Cloud OS TDP for **Fedora Lane**.

Fedora Lane’s e-commerce web estate is roughly **1,600 servers** — mixed OS, long outages when changes go wrong, and ops still building comfort with **containers**. Expansion Pack asks for a **manual RHEL gold image** — not hosted Image Builder at console.redhat.com — that is deployable to cloud and locked down for the web tier.

We built that with **local RHEL Image Builder**: one blueprint in Git. I’ll show the **exact commands** that produce a gold **VHD / AMI**, turn that into a **cloud VM**, and prove the Expansion Pack controls.”

---

## 2. Live walkthrough (5–10 min)

### Story to narrate (keep this diagram verbal or on one slide)

```text
Blueprint (Git)
    → compose commands (Image Builder on builder VM)
    → gold artifact (VHD or AMI)
    → launch commands
    → gold VM (SSH 2222 / httpd 35443)
    → verify (+ reboot)
```

### 2a. Blueprint in Git (1 min)

Screen: `solution/image-builder/fl-rhel-gold.toml`

“This is the recipe — partitions, firewall **2222/35443**, `fladmins`, SSH — versioned in Git. Image Builder reads this; we do **not** click hosted Image Builder.”

### 2b. Commands that create the gold image → VM (3–4 min)

**Prefer Azure** (pure path you ran). Put terminal + cheat sheet on screen. You do **not** need to re-run the long compose live — walk the command chain and say what each step produced.

Narrate:

“**Step 1 — Builder + RHSM** (Image Builder needs a subscribed RHEL VM):”

```bash
cd solution/cloud/azure
./compose-vhd-on-azure-builder.sh
# ssh -i ~/.ssh/fl-gold-poc.pem azureuser@<BUILDER_IP>
# sudo rhc connect
# ./compose-vhd-on-azure-builder.sh --continue <BUILDER_IP>
```

“That runs `image-builder` compose type **vhd** from our blueprint → gold disk file on the builder.”

“**Step 2 — Gold artifact into Azure** (page blob → managed image):”

```bash
./upload-vhd-from-azure-builder.sh <BUILDER_IP>   # if upload step was separate
./create-image.sh                                 # managed image fl-rhel-gold
```

“**Step 3 — Spin VM from the gold image** (not from a stock gallery image):”

```bash
./launch-vm.sh
# → PoC VM IP, SSH port 2222, httpd 35443
```

“Same idea on **AWS**: `./compose-on-builder.sh` → gold **AMI** → `./launch-gold-ami.sh`. One blueprint, two cloud artifacts.”

Optional 20s: open `docs/azure-gold-vhd-poc-runbook.md` or README “How to run” so reviewers see it is repeatable.

### 2c. Prove the gold VM (3–4 min) — end-user view

SSH into the **PoC** VM that came from that image (not the builder):

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<POC_IP>
getenforce
findmnt /var/log /home /tmp /var/tmp
findmnt -o OPTIONS /tmp          # noexec
ss -tln | grep -E '2222|35443'
curl -s http://127.0.0.1:35443/ | head
exit
```

From laptop:

```bash
curl -s http://<POC_IP>:35443/
cd solution/cloud/azure    # or aws
./verify-remote.sh         # show PASS
# mention: az vm restart … / aws reboot, then verify again
```

Say: “These checks are on a VM **launched from the gold image** we just described — Expansion Pack satisfied.”

---

## 3. Value summary (2–5 min)

| Challenge | What the command path delivered |
|---|---|
| Inconsistency | One blueprint → `compose` → repeatable VHD/AMI → identical VMs |
| Risky change | Hardened SSH/sudo baked in; rebuild from Git anytime |
| Container skills gap | httpd **container** on 35443 on every gold VM |
| Cloud | Same factory → Azure **and** AWS proven |

---

## 4. Closing (1–2 min)

“**Next phase:** pilot this Image Builder gold image on non-prod web this month. Kickstart / Image Mode stay in the repo as alternate factories. Stretch: OpenSCAP.

Repo has the runbooks and scripts — anyone can re-run the same commands. Thank you.”

---

## Recording checklist

- [ ] Opening: Fedora Lane challenges + local Image Builder  
- [ ] Showed blueprint in Git  
- [ ] Walked **compose → image → launch** commands (Azure and/or AWS)  
- [ ] Live gold VM: 2222, SELinux, mounts, curl 35443  
- [ ] Verify PASS (+ reboot mentioned)  
- [ ] Value mapped to challenges  
- [ ] Next-phase close  
- [ ] No secrets on screen  

---

## After recording

1. RHSH practice → retrieve recording link.  
2. Google form: topic **Server/Cloud OS TDP** + links in [`part1-submission-guide.md`](./part1-submission-guide.md).  
