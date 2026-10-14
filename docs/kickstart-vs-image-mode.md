# Kickstart vs Image Mode — Fedora Lane dual path

Both paths produce a **gold image** that can meet Expansion Pack security controls. Neither uses **hosted** Image Builder.

| | **Path A — Kickstart** | **Path B — Image Mode (RHEL 10)** |
|---|---|---|
| How OS is made | Installer recipe on a blank disk | Bootable container (`bootc`) → disk |
| You edit | `solution/kickstart/fl-rhel-gold.ks` | `solution/image-mode/Containerfile` |
| Convert / export | `qemu-img` from libvirt disk | Local `bootc-image-builder` |
| Best for | Fast TDP checklist / classic ops | Scaling ~1,600 hosts with less drift |
| Partition specs | Natural LVM in Kickstart | Via `bib-config.toml` + verify on VM |
| httpd | Podman container :35443 | Same |
| Cloud | AWS or Azure Blank OPEN | Same |

## Recommendation for the demo

1. **Fully prove one path** on cloud (Kickstart is safest).  
2. **Show the other path’s artifacts** (Containerfile or Kickstart) and explain scale.  
3. Message: *Kickstart for trusted first gold image; Image Mode for fleet-scale Day-2.*  
