# PoC steps — dual gold-image paths

This Expansion Pack solution offers **two** manual factories (no hosted Image Builder):

| Path | What it is | Detailed steps |
|---|---|---|
| **A — Kickstart** | Classic RHEL install recipe → disk → cloud | [poc-steps-kickstart.md](./poc-steps-kickstart.md) |
| **B — Image Mode** | RHEL 10 bootc Containerfile → local BIB → cloud | [poc-steps-image-mode.md](./poc-steps-image-mode.md) |

Compare: [kickstart-vs-image-mode.md](./kickstart-vs-image-mode.md)

## Shared end state (both paths)

On the cloud VM you must show:

- Separate `/var/log`, `/home`, `/tmp`, `/var/tmp` (&lt; 5 GiB each)  
- `/tmp` **noexec**  
- SELinux **enforcing**  
- SSH **2222** (keys only, no root)  
- httpd **container** on **35443** + dummy index  
- Firewall only those ports  
- `fladmins` + passworded sudo  
- Survives **reboot**  

Verifier (both paths):

```bash
sudo bash solution/scripts/verify-gold-image.sh
```

## Suggested PoC plan for your group

1. **Primary demo:** complete Path A **or** Path B end-to-end on AWS *or* Azure OPEN.  
2. **Secondary story:** walk the other path’s source in Git (2 minutes).  
3. Stretch: OpenSCAP + second cloud (`solution/openscap/`, cloud docs).  

## RHDP reminder

Use **AWS Blank OPEN** / **Azure Blank OPEN**. No public credentials. Shut down when finished.
