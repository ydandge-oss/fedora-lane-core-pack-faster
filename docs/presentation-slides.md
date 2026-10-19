# Slide outline — Server/Cloud OS TDP (~15 min)

**Customer-ready narrative (paste into Google Docs):**  
[`customer-presentation-fedora-lane.md`](./customer-presentation-fedora-lane.md)

**Spoken script:** [`presentation-script-part1-video.md`](./presentation-script-part1-video.md)

| # | Slide | One-liner |
|---|---|---|
| 1 | Title | Fedora Lane Expansion Pack — RHEL gold image (local Image Builder) |
| 2 | Agenda | Challenges · solution · how it works · controls · ops · scale · next |
| 3 | Challenges | Inconsistency · risky change · container skills gap |
| 4 | Solution | Blueprint in Git → compose AMI/VHD → launch gold VMs |
| 5 | Architecture | Factory → AWS AMI + Azure VHD → verified web node |
| 6 | Path to VM | Compose → register → launch → firstboot → verify |
| 7 | Controls | Partitions · SELinux · SSH 2222 · httpd:35443 · fladmins · firewall |
| 8 | Ops | Console/CLI without scripts; SG/NSG + User data |
| 9 | Evidence | Live verify + reboot (AWS and Azure proven) |
| 10 | Scale | Freeze image · launch waves · replace · recompose for Day-2 |
| 11 | Value | Map each challenge → deliverable |
| 12 | Next | Non-prod pilot · optional OpenSCAP / Kickstart / Image Mode |
| 13 | Close | Repo link · Q&A |
