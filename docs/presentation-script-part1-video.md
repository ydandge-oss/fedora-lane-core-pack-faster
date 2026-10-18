# Part 1 practice video — ~15 minutes  
## Server/Cloud OS TDP · Expansion Pack gold image

**Audience:** Casey Novak / Alex Lee (practice via RHSH)  
**Record:** RHSH practice activity → submit recording link + deliverable links on the Google form  
**Topic on form:** Server/Cloud OS TDP  

Use this script as a teleprompter. Keep Git + one live PoC VM ready (Azure or AWS).

---

## Timing map (required structure)

| Segment | Time | What you do |
|---|---|---|
| Opening | 1–2 min | Team + restated challenges |
| Live walkthrough | 5–10 min | End-user view of the solution |
| Value summary | 2–5 min | Map solution → challenges |
| Closing | 1–2 min | Next-phase recommendations |
| **Total** | **~15 min** | |

---

## 1. Opening (1–2 min)

“Hi, I’m [Name], Junior Consultant on the FASTER Server/Cloud OS TDP for **Fedora Lane**.

Fedora Lane’s e-commerce web estate is roughly **1,600 servers** — mixed OS, long outages when changes go wrong, and ops still building comfort with **containers**. Expansion Pack asks for a **manual RHEL gold image** — not hosted Image Builder at console.redhat.com — that is deployable to cloud and locked down for the web tier.

We built that gold image with **local RHEL Image Builder**: one blueprint in Git, composed to **AMI for AWS** and **VHD for Azure**, both proven with verify and reboot.”

---

## 2. Live walkthrough (5–10 min)

### 2a. Source of truth (2 min)

Screen: GitHub `expansion-tdp-solution`

- README — purpose + how to run  
- `solution/image-builder/fl-rhel-gold.toml` — partitions, firewall 2222/35443, `fladmins`, SSH  
- `docs/solution-overview.md` — challenge mapping  
- Point to runbooks: Azure VHD and/or AWS AMI  

“Everything needed to rebuild is in this repo — no secrets committed.”

### 2b. Live PoC VM — end-user view (5–7 min)

Prefer the cloud you have live (Azure `fladmin1@…:2222` or AWS). Narrate while you type:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<IP>
getenforce
findmnt /var/log /home /tmp /var/tmp
findmnt -o OPTIONS /tmp          # show noexec
ss -tln | grep -E '2222|35443'
curl -s http://127.0.0.1:35443/ | head
exit
```

From your laptop:

```bash
curl -s http://<IP>:35443/
# optional: show verify PASS
cd solution/cloud/azure   # or aws
./verify-remote.sh
```

Say: “Same Expansion Pack controls on Azure VHD and AWS AMI — one blueprint, two cloud artifacts.”

### 2c. How it was built (1 min — keep short)

“Builder VM → `image-builder` compose → `vhd` or `ami` → launch from that image → firstboot for SELinux ports, noexec, httpd container. Full steps are in the Azure and AWS runbooks in the repo.”

---

## 3. Value summary (2–5 min)

| Challenge | What we delivered |
|---|---|
| Inconsistency | One blueprint → repeatable gold AMI / VHD |
| Risky / untraceable change | Hardened SSH (2222, no root, keys only), sudo group, Git history |
| Container skills gap | httpd **in a container** on 35443 with a simple index page |
| Cloud reality | Proven on **AWS and Azure** Blank OPEN with reboot |

“This is the Expansion Pack baseline for the web tier — standardized, inspectable, and redeployable.”

---

## 4. Closing (1–2 min)

“**Next phase:** pilot this Image Builder gold image on non-prod web nodes this month; keep Kickstart / Image Mode in the repo as alternate factories if the org prefers those workflows; stretch OpenSCAP CIS.

Repo and docs are the handoff. Happy to take questions in Part 2 live. Thank you.”

---

## Recording checklist (before you hit stop)

- [ ] Opening stated Fedora Lane challenges  
- [ ] Showed Git README + blueprint  
- [ ] Live SSH 2222 + SELinux + mounts + curl 35443  
- [ ] Mentioned verify + reboot (or showed them)  
- [ ] Value mapped to challenges  
- [ ] Closed with next-phase recommendation  
- [ ] No passwords / access keys shown on screen  

---

## After recording

1. Complete RHSH practice activity and **retrieve the recording link**.  
2. Submit Google form: topic **Server/Cloud OS TDP** + recording URL + GitHub branch URL + doc links.  
3. See [`part1-submission-guide.md`](./part1-submission-guide.md).  
