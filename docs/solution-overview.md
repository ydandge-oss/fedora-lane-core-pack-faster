# Solution Overview — Platform Consistency Pilot for Fedora Lane  
## Junior Consultant · Core Pack practice

## 1. Purpose

This solution shows Fedora Lane a **repeatable first step** against the Core Pack challenges: stop treating every Linux location as a snowflake, prove **config-as-code** across a model of NA DC / EMEA DC / boutique / cloud hosts, and run a **Boutique Inventory Sync** sample service in a portable way — the kind of custom tool the Core Pack already names as part of their estate.

> **Scope note:** The Core Pack states that each **TDP Expansion Pack** will prescribe the Red Hat technology and exact build for that Practice Activity. This pilot is a **Core Pack–aligned practice build** (Ansible + portable app). When your Expansion Pack arrives, extend or replace `solution/` with that TDP’s requirements and keep this challenge → value narrative.

## 2. Customer challenges addressed

| Core Pack challenge | How this solution addresses it |
|---|---|
| Siloed hybrid/multi-cloud ops | Single Git repo + Ansible inventory grouping DC, boutique, and cloud host classes |
| Configuration drift | Idempotent playbooks for chrony, packages, sshd baseline, banner |
| Automation friction | One `site.yml` entry point instead of per-site manual SSH |
| Unpredictable environments blocking modernization | Same inventory-sync image runs locally via Compose — portable pattern for later on-prem/cloud |
| Portability pain | Containerized sample service; no host-specific snowflake install |
| COTS constraints | Does **not** touch SAP internals; syncs *around* SAP ↔ PoS as the Core Pack describes |
| Security baseline / audit toil | Documented baseline role + health/status endpoints for evidence; secrets via env, not baked into image |

## 3. High-level architecture

```
GitHub (source of truth)
        │
        ├─ Ansible inventory ──► host groups:
        │     na_dc · emea_dc · boutiques · cloud_linux
        │         │
        │         └─ playbooks/site.yml
        │               ├─ common baseline (chrony, packages)
        │               └─ security baseline (sshd, banner)
        │
        └─ inventory-sync (Python FastAPI)
              └─ Docker Compose → /health · /api/v1/sync/status
```

**Pilot topology (fictional model hosts — not live Fedora Lane servers)**

| Group | Represents | Core Pack mapping |
|---|---|---|
| `na_dc` | Virginia DC Linux | Primary DC |
| `emea_dc` | Frankfurt DC Linux | EMEA DR / performance |
| `boutiques` | Flagship closet servers | Paris / Tokyo–style closets |
| `cloud_linux` | AWS/Azure Linux instances | Hybrid cloud Linux estate |

## 4. Key design decisions

### Why Ansible first (for Core Pack)

1. Casey’s mandate is standards across a **diverse Linux fleet** — Ansible is the natural control plane for that story.  
2. Alex rejects science projects; playbooks are proven, reviewable, and runnable with `--check`.  
3. Ren can treat Git history + playbook output as baseline evidence.  
4. Expansion Packs can later add OpenShift, AAP, ACS, etc. without throwing away the GitOps habit.

### Why Boutique Inventory Sync as the sample app

1. Named explicitly in the Core Pack (SAP ↔ local PoS).  
2. Small enough to demo in minutes; important enough to feel real to Cameron.  
3. Shows portability (container) without pretending we migrated SAP.

### Why GitHub instead of Consulting GitLab

The Core Pack asks for the cohort FASTER GitLab sub-group as source of truth. For this practice workspace we use **GitHub** (account attached to Cursor). If your program requires GitLab submission, mirror or push the same tree there — content stays identical.

## 5. What we implemented

1. Ansible inventory modeling Fedora Lane host classes (`solution/ansible/inventory/`)  
2. `common` and `security_baseline` roles (`solution/ansible/roles/`)  
3. `site.yml` orchestration playbook  
4. Boutique Inventory Sync FastAPI app + Docker Compose (`solution/inventory-sync/`)  
5. Junior consultant docs + Part 1 / Part 2 presentation scripts (`docs/`)  

## 6. Challenge → Solution → Demo mapping

| Challenge | Artifact | Demo moment |
|---|---|---|
| Drift / silos | Inventory + `site.yml` | Show host groups; run playbook `--check` |
| Automation friction | Idempotent roles | Re-run playbook; show “ok / changed” |
| Modernization / portability | `inventory-sync` Compose | `curl /health` and `/api/v1/sync/status` |
| Security / audit | Security role + no secrets in Git | Show `.gitignore`, env-based token, banner/sshd tasks |
| COTS coexistence | Sync API around SAP (not inside SAP) | Explain boundary in walkthrough |

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Expansion Pack changes required tech | Keep challenge mapping; swap `solution/` internals |
| Demo against real customer hosts | Use local/demo inventory only; redacted examples |
| Scope creep into PCI CHD | Pilot is non-cardholder pattern; call out Ren’s path for CHD later |
| Over-promising full hybrid unification | Position as **first milestone**, not silver bullet (Alex language) |

## 8. Recommended next phase (after Core Pack pilot)

1. Apply the same Git + automation pattern to the **specific Red Hat technology** in your next Expansion Pack.  
2. Workshop with Casey and Alex: inventory truth source for the real Linux fleet.  
3. With Ren: map baseline controls to PCI/GDPR/CCPA evidence packs.  
4. With Cameron: pick the next e-commerce microservice candidate after inventory sync.
