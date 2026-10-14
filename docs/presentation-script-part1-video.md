# 15-minute speaker script — Part 1 (Recorded video)  
## Junior Consultant · Fedora Lane Core Pack

**Presenter:** Yash Dandge, Junior Consultant, Red Hat  
**Mode:** Record yourself for AI / manager / FASTER feedback  
**Timebox:** 15 minutes total  

> Tip: Pre-start the inventory-sync API (`uvicorn` or Docker Compose) and open two terminals (Ansible + curl) before you hit record. Part 1 is about clarity and structure — you can glance at notes more than in Part 2, but still speak to camera.

---

## Opening (1:30)

**Why we’re here**  
“Thanks for watching. This is my Part 1 practice presentation for the Fedora Lane Core Pack. I’m here because Fedora Lane asked Red Hat Consulting to help them address the operational complexity of a global hybrid and multi-cloud estate — so they can modernize e-commerce and prove security without more snowflake operations.”

**Team intro**  
“I’m Yash Dandge, Junior Consultant. I’ve designed and built a hands-on Platform Consistency Pilot against the Core Pack challenges.”

**Confirm the problem**  
“From the Core Pack: Fedora Lane runs Virginia and Frankfurt data centers on VMware, boutique server closets, AWS for e-commerce, and Azure for specific workloads. Teams operate in silos. That creates configuration drift, blocks consistent automation, makes application portability hard, and turns PCI, GDPR, and CCPA evidence into a major undertaking.”

**Objective**  
“In the next fifteen minutes I’ll show what I built, walk through it live, and connect it back to those challenges.”

**Agenda**  
“Opening done. Next: live walkthrough, then value summary, then one concrete next step.”

---

## Live walkthrough (8:00)

### 1. Challenges → approach (1:00)

“I chose a first milestone Alex and Casey can accept: **Git as source of truth**, **Ansible** for Linux baseline consistency across a model of NA DC, EMEA DC, boutiques, and cloud Linux, plus a **Boutique Inventory Sync** sample service — named in the Core Pack — running portably in containers.”

### 2. Show the repo (1:00)

On screen: GitHub README.

“Thorough README, docs for the client, and `solution/` with Ansible and the sync API. No credentials in Git.”

### 3. Show Ansible inventory + dry-run (3:00)

```bash
cd solution/ansible
ansible-inventory -i inventory/hosts.yml --graph
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check
```

**Tell → show → tell**  
- **Tell:** “You’ll see host groups that mirror Fedora Lane’s hybrid estate, then a check-mode run of the baseline.”  
- **Show:** graph + `--check` output.  
- **Tell:** “That’s how we attack drift and manual SSH — Casey’s central control without firefighting each boutique closet one by one.”

### 4. Show Inventory Sync API (2:30)

```bash
# API should already be running (uvicorn or docker compose)
curl -s http://127.0.0.1:8080/health | jq .
curl -s http://127.0.0.1:8080/api/v1/sync/status | jq .
```

**Tell → show → tell**  
- **Tell:** “This stands in for the Boutique Inventory Sync between SAP and local PoS — we don’t touch SAP internals.”  
- **Show:** health + sync status JSON.  
- **Tell:** “Cameron gets a portable modern service pattern; Ren sees config via environment, not secrets in the image.”

### 5. Critical decisions (30–45 sec)

“Two decisions: Ansible first for the Linux fleet story in the Core Pack; and a **small** app that coexists with COTS instead of pretending we replatformed SAP. Expansion Packs will layer the specific Red Hat TDP tech on this habit of Git + repeatable demos.”

---

## Value summary (3:00)

| Stakeholder | What they get from this pilot |
|---|---|
| **Casey** | One inventory + playbooks instead of per-site SSH drift |
| **Alex** | Manageable first milestone — not a silver-bullet platform science project |
| **Cameron** | Portable sync service pattern for modernization without waiting on perfect infra |
| **Ren** | Documented baseline + no secrets in Git; clearer audit story than tribal knowledge |
| **Anya** | Small, real progress toward agility and CX — not just lights-on |

**Future possibilities (keep short)**  
“When each TDP Expansion Pack lands, we apply the same Git discipline to that Red Hat technology — and expand inventory sync toward real CI/CD and environment parity.”

---

## Closing (1:30)

**Core message**  
“Fedora Lane’s Core Pack challenges start with hybrid complexity and drift. The fix begins with a single source of truth and automation they can trust — proven with a real boutique sync pattern.”

**One next step**  
“I’d propose a short workshop with Casey and Alex to map this inventory model to their real Linux estate before we layer the next TDP Expansion Pack build.”

**Close**  
“That’s my Part 1. Feedback welcome on structure, technical accuracy, and customer language. Thank you.”

---

## Timing cheat sheet (Part 1)

| Segment | Target |
|---|---|
| Opening | 1:30 |
| Walkthrough | 8:00 |
| Value | 3:00 |
| Closing | 1:30 |
| Buffer | 1:00 |
