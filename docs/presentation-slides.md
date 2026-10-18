# Slide outline — Server/Cloud OS TDP (~15 min)

Use with [`presentation-script-part1-video.md`](./presentation-script-part1-video.md).

1. **Title** — Fedora Lane Expansion Pack: RHEL gold image (Image Builder)  
2. **Team + agenda** — Opening · live walkthrough · value · next steps  
3. **Problem** — Inconsistent estate · untraceable change · container skills gap  
4. **Want** — One secure RHEL web baseline for AWS and Azure  
5. **Product** — Local RHEL Image Builder (blueprint → compose) — not hosted console  
6. **Architecture** — Blueprint → compose commands → `ami`/`vhd` → launch → VM  
7. **Command path** — `compose-*` → `create-image` / AMI → `launch-*` → `verify-remote`  
8. **Controls** — Partitions · SELinux · SSH 2222 · httpd:35443 · fladmins · firewall  
9. **Evidence** — Live gold VM + verify + reboot (AWS and Azure proven)  
10. **Value** — Map each challenge → deliverable  
11. **Next step** — Non-prod pilot; alternates (Kickstart / Image Mode); OpenSCAP stretch  
12. **Close** — Repo as source of truth · Q&A in Part 2  
