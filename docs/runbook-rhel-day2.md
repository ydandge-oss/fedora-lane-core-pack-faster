# Day-2 runbook — RHEL golden image pilot (no Ansible)

For Casey Novak (Linux Eng) and Alex Lee (Infra/Ops).

## 1. Register a new host from the golden image

```bash
# After first boot from Image Builder artifact
sudo subscription-manager register --org=<ORG> --activationkey=<KEY>   # use secrets vault — not Git
sudo subscription-manager attach --auto   # if required by your account model
sudo insights-client --register
```

Confirm:

```bash
sudo subscription-manager status
sudo insights-client --status
```

## 2. Critical / High CVE patching (“within days”)

Core Pack policy: Critical/High CVEs patched **within days** of discovery.

```bash
# See applicable updates
sudo dnf updateinfo list security

# Apply security updates in a maintenance window
sudo dnf update --security -y
# or targeted advisory:
# sudo dnf update --advisory=RHSA-XXXX:XXXX -y

sudo insights-client
reboot   # if kernel or requires-reboot advisories say so
```

**Ops model:** Insights Advisor / Vulnerability shows fleet risk; Casey schedules wave by environment (lab → boutique non-CHD → DC app → cloud). No persistent SSH config drift — patch, reboot if needed, done.

## 3. Avoid snowflake changes

| Do | Don’t |
|---|---|
| Change the **blueprint** and rebuild image for day-0 standards | Hand-edit 40 boutique servers differently |
| Use documented `dnf` / Insights remediation for CVEs | Leave hosts unregistered “because it’s just a closet” |
| Track exceptions in a short change record | Silent SSH tweaks that nobody can audit |

## 4. Run the sample inventory-sync service on RHEL

```bash
# On the RHEL host (Podman is in the blueprint package set)
cd /opt/fl/inventory-sync   # or your deploy path
podman build -t fl-inventory-sync:pilot .
podman run -d --name fl-inventory-sync -p 8080:8080 \
  -e SYNC_API_TOKEN=demo-not-a-real-secret \
  fl-inventory-sync:pilot

curl -s http://127.0.0.1:8080/health
```

## 5. Evidence for Ren (security / audit)

- Host registered to Insights  
- Same package baseline from golden image  
- `dnf updateinfo` / Insights vulnerability export for quarterly audit packs  
- SELinux enforcing (Kickstart/Image default posture)  

## 6. Later phase (after you learn Ansible)

Keep the golden image. Add Ansible Automation Platform or system roles **after** day-0 to prevent config drift over time. Image = birth certificate; Ansible = ongoing lifecycle — not required for this branch’s demo.
