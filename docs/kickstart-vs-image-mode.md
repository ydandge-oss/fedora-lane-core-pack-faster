# Factory comparison (Expansion Pack)

| | **Primary: Image Builder** | Kickstart | Image Mode (bootc) |
|---|---|---|---|
| What | Local `image-builder` + blueprint TOML | Anaconda kickstart | Containerfile → bootc-image-builder |
| Output | `ami` / `vhd` / `qcow2` | Disk / qcow2 → import | Disk / qcow2 → import |
| Best for | Official compose path + cloud formats | Classic install familiarity | Day-2 OS updates as containers |
| PoC doc | [poc-steps-image-builder.md](./poc-steps-image-builder.md) | [poc-steps-kickstart.md](./poc-steps-kickstart.md) | [poc-steps-image-mode.md](./poc-steps-image-mode.md) |

All three target the **same** Expansion Pack checklist. Live-prove **Image Builder**; keep the others as backup stories.
