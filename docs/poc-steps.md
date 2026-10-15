# PoC steps — Expansion Pack gold image

**Primary path** uses local **RHEL Image Builder** (official compose procedure). Alternates remain available.

| Path | What it is | Detailed steps |
|---|---|---|
| **Primary — Image Builder** | Blueprint TOML → local `image-builder` compose → `ami`/`vhd` | [poc-steps-image-builder.md](./poc-steps-image-builder.md) |
| Alt A — Kickstart | Classic RHEL install recipe → disk → cloud | [poc-steps-kickstart.md](./poc-steps-kickstart.md) |
| Alt B — Image Mode | RHEL 10 bootc Containerfile → local BIB → cloud | [poc-steps-image-mode.md](./poc-steps-image-mode.md) |

Upstream Image Builder: [image-builder-description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

## Shared end state (all paths)

On the cloud VM you must show:

- Separate `/var/log`, `/home`, `/tmp`, `/var/tmp` (&lt; 5 GiB each)  
- `/tmp` **noexec**  
- SELinux **enforcing**  
- SSH **2222** (keys only, no root)  
- httpd **container** on **35443** + dummy index  
- Firewall only those ports  
- `fladmins` + passworded sudo  
- Survives **reboot**  

Verifier:

```bash
sudo bash solution/scripts/verify-gold-image.sh
```

## Suggested PoC plan

1. **Primary demo:** Image Builder compose → AWS *or* Azure OPEN → verify + reboot.  
2. **If asked:** 60-second Git walk of Kickstart or Image Mode.  
3. Stretch: OpenSCAP + second cloud (`solution/openscap/`, cloud docs).  

## RHDP reminder

Use **AWS Blank OPEN** / **Azure Blank OPEN**. No public credentials. Shut down when finished.
