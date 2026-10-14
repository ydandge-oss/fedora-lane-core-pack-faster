# Follow-up email — within 2 days of Part 2

**To:** Casey Novak; Alex Lee *(SME personas)*  
**Cc:** [Pod Host]; [Manager]; faster@redhat.com  
**Subject:** Fedora Lane — RHEL gold image (Server/Cloud OS TDP) follow-up

---

Hi Casey, Alex,

Thank you for the time on [date] discussing the Server/Cloud OS Expansion Pack solution.

## Overview

We demonstrated a **manually built RHEL gold image** for Fedora Lane’s e-commerce web fleet, addressing:

1. Inconsistent server environment (~1,600 hosts / mixed OS)  
2. Untraceable administrative changes and extended outages  
3. Operational skills gap for container workloads  

Key controls shown: separate `/var/log`, `/home`, `/tmp` (noexec), `/var/tmp`; SELinux enforcing; SSH **2222**; httpd **container** on **35443**; firewall limited to those ports; `fladmins` with passworded sudo; root/password SSH disabled; reboot persistence.

## Repository

https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution  

(Please ensure `mflaim-eng` has access if using the private fork.)

## Next steps

1. Pilot gold image AMI/VHD on non-prod web nodes.  
2. Align admin keys / IdP with Ren’s access standards.  
3. Optional: OpenSCAP CIS hardening pass; second cloud image.  
4. Pair with Web Console / Session Recording for change visibility.

## Parking-lot answers

| Question | Answer |
|---|---|
| 1 | *[fill after call]* |
| 2 | *[fill after call]* |

Thanks again,  
Yash Dandge  
Junior Consultant, Red Hat  
[email]
