# 15-minute speaker script — Part 2 (Live POD presentation)  
## Junior Consultant · Fedora Lane Core Pack

**Presenter:** Yash Dandge, Junior Consultant, Red Hat  
**Audience (SME personas):** Alex Lee (Infra/Ops), Casey Novak (Linux Eng) — peers/manager may listen  
**Timebox:** 15 minutes + Q&A after  

> Live tip: Speak *to* Alex and Casey by name. Do not read the script. Pre-start the inventory-sync API. Have parking-lot notepad ready for the follow-up email.

---

## Opening (1:30)

**Why we’re here**  
“Thanks for the time today. We’re here because Fedora Lane asked Red Hat Consulting to help tackle the operational complexity of your global hybrid and multi-cloud environment — so Application Development can modernize without Infrastructure absorbing another unmanaged snowflake.”

**Team intro**  
“I’m Yash Dandge, Junior Consultant. I’ve been hands-on building a Platform Consistency Pilot against the challenges in your Core Pack.”

**Confirm the problem**  
“Alex, Casey — you’ve got Virginia and Frankfurt on VMware, boutique closets, AWS for e-commerce, Azure for specific apps. Without unified management, servers drift, automation stays manual, e-commerce portability suffers, and Ren’s audit evidence gets harder every quarter.”

**Objective**  
“Today I’ll walk through the pilot I built, show it live, and leave you with one concrete next step.”

**Agenda**  
“Live walkthrough, short value summary mapped to your teams, then close. Happy to take deep questions after — or park them for email within two days.”

---

## Live walkthrough (8:00)

### 1. Architecture in one breath (45 sec)

“GitHub is the source of truth. Ansible inventory models `na_dc`, `emea_dc`, `boutiques`, and `cloud_linux`. Playbooks apply a common and security baseline. Separately, a Boutique Inventory Sync API — the tool class your Core Pack already describes between SAP and PoS — runs in Docker Compose so we can prove portability without touching SAP.”

### 2. Critical decision (45 sec)

“I started with **Ansible + Git**, not a greenfield platform rewrite. Casey, that matches your need for centralized Linux standards. Alex, it’s something your team can review with `--check` before it touches anything real.”

### 3. Show inventory + check mode (2:30)

```bash
cd solution/ansible
ansible-inventory -i inventory/hosts.yml --graph
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check
```

**Tell → show → tell**  
- **Tell:** “You’ll see the hybrid host model, then a dry-run of the baseline.”  
- **Show:** graph + check output.  
- **Tell:** “That’s the opposite of boutique SSH firefighting.”

### 4. Show working sync service (3:00)

```bash
curl -s http://localhost:8080/health | jq .
curl -s http://localhost:8080/api/v1/sync/status | jq .
```

**Tell → show → tell**  
- **Tell:** “This is the Boutique Inventory Sync pattern — SAP stays the system of record; we modernize the sync edge.”  
- **Show:** endpoints.  
- **Tell:** “Cameron gets a portable service; Ren sees secrets kept out of the image.”

Optional polish if time:

```bash
# Re-run playbook to show idempotency
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check
```

### 5. What we deliberately did *not* do (30 sec)

“We did not claim a full multi-cloud control plane or a SAP migration. Anya asked for small, valuable, real. This is that first milestone.”

---

## Value summary (3:00)

| Stakeholder | Value |
|---|---|
| **Casey** | Enforceable Linux baseline from Git |
| **Alex** | Reviewable automation; Day-2 starts with inventory truth |
| **Cameron** | Portable sync service as modernization proof point |
| **Ren** | Baseline + secret hygiene → less tribal audit pain |
| **Anya** | Tangible step toward agility without boiling the ocean |

**Future left open**  
“Third-party integrations on the sync API, Expansion Pack TDP technologies layered on the same Git discipline, tighter evidence packs for Ren.”

---

## Closing (1:30)

**Core message**  
“Hybrid complexity and drift are the Core Pack’s root issue. Git plus automation, proven with a real boutique sync pattern, is how we start realized value.”

**One next step**  
“I’d like a **90-minute workshop** with you both — Casey and Alex — to map this inventory model to your actual Linux estate and agree what ‘done’ looks like before the next Practice Activity Expansion Pack build.”

**Close**  
“I’ll send a follow-up within two days with the repo link, solution overview, and answers to anything we park. Questions?”

---

## Live Q&A posture

- Answer in 30–60 seconds; offer to deep-dive offline.  
- If you don’t know: “Good question — I’ll confirm and include it in the follow-up email.”  
- See [sme-qa-prep.md](./sme-qa-prep.md).

---

## Timing cheat sheet (Part 2)

| Segment | Target |
|---|---|
| Opening | 1:30 |
| Walkthrough | 8:00 |
| Value | 3:00 |
| Closing | 1:30 |
| Buffer before Q&A | 1:00 |
