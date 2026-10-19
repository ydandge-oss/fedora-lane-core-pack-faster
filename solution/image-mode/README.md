# Path B — RHEL 10 Image Mode (bootc) gold image

Official Red Hat approach: build the OS as a **bootable container**, then convert to a cloud disk (AMI / raw / qcow2) with **local** `bootc-image-builder` (not the hosted console.redhat.com Image Builder service).

Docs: [Using image mode for RHEL (RHEL 10)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/introducing-image-mode-for-rhel)

## Layout

| Path | Purpose |
|---|---|
| [`Containerfile`](./Containerfile) | RHEL 10 bootc gold image definition |
| [`config/`](./config/) | SSH, sudo, firewall, mounts, httpd unit drop-ins |
| [`html/`](./html/) | Dummy index.html for httpd container |
| [`bib-config.toml`](./bib-config.toml) | `bootc-image-builder` disk customizations (separate mounts &lt; 5 GiB) |
| [`scripts/build-bootc.sh`](./scripts/build-bootc.sh) | Build bootc OCI image with Podman |
| [`scripts/build-disk.sh`](./scripts/build-disk.sh) | Convert bootc → AMI/raw/qcow2 locally |

## When to use this path

- Show RHEL 10 **Image Mode** as the path to operate ~1,600 servers with less drift  
- Same Expansion Pack security controls as Kickstart path  
- Stretch / differentiator in the live presentation  

**Graded demo tip:** Prove either Path A (Kickstart) **or** Path B (Image Mode) fully on AWS/Azure. Mention the other as the complementary factory. Path A is the safest checklist match; Path B is the scale story.

## High-level flow

```text
Containerfile (rhel10/rhel-bootc)
        │ podman build
        ▼
  localhost/fl-rhel10-bootc-gold:latest
        │ bootc-image-builder (+ bib-config.toml)
        ▼
  AMI / raw / qcow2  →  AWS or Azure Blank OPEN VM
        │
        ▼
  verify-gold-image.sh  (same checks as Kickstart path)
```

## Prerequisites

- Subscribed RHEL 10 builder (or RHDP) with Podman  
- Access to `registry.redhat.io` (`podman login`)  
- For disk conversion: ability to run `quay.io/centos-bootc/bootc-image-builder` (or RHEL-documented equivalent) with `--privileged`  

See [`../../docs/poc-steps-image-mode.md`](../../docs/poc-steps-image-mode.md).
