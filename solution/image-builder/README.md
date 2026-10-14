# Image Builder — Fedora Lane RHEL golden image

## Purpose

Bake a **repeatable RHEL starting point** for Virginia DC, Frankfurt DC, boutique closets, and cloud Linux VMs so hosts do not begin life as snowflakes.

## Blueprint

- File: [`fl-rhel-baseline.toml`](./fl-rhel-baseline.toml)  
- Includes: chrony, firewalld, Insights client, Cockpit, OpenSSH, Podman, python3  
- Timezone/NTP and SSH key customization placeholders  

## Build steps (RHEL builder host)

```bash
# Install (once)
sudo dnf install -y osbuild-composer composer-cli cockpit-composer
sudo systemctl enable --now osbuild-composer.socket

# Push blueprint
sudo composer-cli blueprints push fl-rhel-baseline.toml
sudo composer-cli blueprints show fl-rhel-baseline

# Compose (pick output for your target)
sudo composer-cli compose start fl-rhel-baseline qcow2   # VMware/libvirt lab
# sudo composer-cli compose start fl-rhel-baseline ami    # AWS (with proper setup)
# sudo composer-cli compose start fl-rhel-baseline image-installer

# Watch / download
sudo composer-cli compose status
# COMPOSITE_ID=<uuid from status>
sudo composer-cli compose image "$COMPOSITE_ID"
```

## Mapping to Fedora Lane

| Stakeholder | Why this matters |
|---|---|
| Casey | One approved image = enforceable Linux standard |
| Alex | New hosts are predictable; less “unique boutique server” ops |
| Ren | Baseline packages + Insights client from day 0 |
| Cameron | App teams inherit a known OS under services |

## Lab without a full builder

If Image Builder is not available yet:

1. Walk the TOML in the presentation (tell).  
2. Use any RHEL 9 lab VM and manually install the same package set (show).  
3. Still run Insights registration steps from the Day-2 runbook.  
4. Build the real compose before Part 2 if possible.  
