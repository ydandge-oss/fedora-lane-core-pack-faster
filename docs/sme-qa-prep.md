# SME Q&A prep — Alex & Casey  
## RHEL golden image branch (no Ansible)

### 1. Why not Ansible from day one?
We can deliver day-0 consistency with Image Builder without automation coding. Ansible is Phase 2 for drift *after* provisioning. Image first is lower risk for a stretched ops team.

### 2. How do boutiques stay consistent if they’re “independently managed”?
Independence of site ≠ independence of image. They deploy the same approved qcow2/ISO; local network settings differ, baseline doesn’t.

### 3. What about Critical/High CVEs within days?
Insights shows exposure; `dnf update --security` (or advisory-targeted updates) in a maintenance wave. Rebuild the golden image so *new* hosts include fixes going forward.

### 4. Does this replace VMware?
No. RHEL runs **on** VMware (and cloud) as the guest OS standard. Hypervisor stays; OS sprawl shrinks.

### 5. How does this help SAP / PoS?
We standardize the Linux under and around those stacks. Inventory sync stays at the edge — we don’t re-platform SAP in this pilot.

### 6. What if Image Builder isn’t ready in our lab?
Blueprint in Git is still the source of truth; we can compose on a small builder host or use a stand-in RHEL VM with the same package set for the demo, then produce the real artifact for Virginia lab.

### 7. Won’t hosts drift after months anyway?
Yes — that’s why Phase 2 is config management. This pilot stops the worst problem: **every new host starting different**.

### 8. Why is Insights in the image?
So Ren gets visibility as soon as a host is born — not after someone remembers to install an agent weeks later.
