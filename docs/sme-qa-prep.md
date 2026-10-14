# SME Q&A prep — Alex Lee & Casey Novak  
## Core Pack live call

Aim for **30–60 second** answers. Park deep dives for email.

### 1. Why start with Ansible / Git instead of a big platform project?
**Alex / Casey:** Because the Core Pack root issue is drift and siloed ops. Git + Ansible is a proven, reviewable control plane for the Linux fleet. It makes Day-2 better before we layer a larger TDP platform.

### 2. How does this help boutique closets that are “independently managed” today?
**Casey:** We model them as an inventory group with the same baseline roles. Independence of *location* does not require independence of *standards*.

### 3. Won’t this just become another thing my stretched team has to run?
**Alex:** Check-mode and idempotent playbooks reduce emergency SSH. The pilot is deliberately small. We agree ownership and a workshop before expanding scope.

### 4. How do you avoid touching SAP / breaking COTS?
We don’t change SAP. The Inventory Sync sample sits at the edge (SAP ↔ PoS), matching the Core Pack description of that custom tool.

### 5. What about security and audits for Ren?
Baseline role + secrets kept out of Git + health/status endpoints create evidence artifacts. Phase 1 is a consistency pattern, not a full PCI CHD redesign.

### 6. How does this help Cameron’s Kubernetes / CI/CD ambition?
Portable containerized sync is a stepping stone: same artifact, fewer “works on this boutique server” surprises. Expansion Pack TDPs can extend the platform story later.

### 7. What happens when Critical/High CVEs must be patched within days?
Baseline automation is how you *roll* patches consistently. The pilot shows the delivery mechanism; patch content comes from your vulnerability process.

### 8. Is GitHub acceptable vs Consulting GitLab?
Core Pack specifies cohort GitLab. This practice repo is on GitHub for Cursor-linked workflow; we can mirror to GitLab for formal submission without changing content.
