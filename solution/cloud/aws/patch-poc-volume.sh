#!/usr/bin/env bash
# Offline-patch the gold PoC root volume: NOPASSWD + fixed firstboot.
# Attaches the PoC root volume to the Image Builder EC2 (which has working sudo).
#
# Usage:
#   ./patch-poc-volume.sh                 # uses aws-outputs.json + builder-outputs.json
#   ./patch-poc-volume.sh <poc-instance> <builder-instance>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

need_aws
load_env
SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY/#\~/$HOME}"
KEY="$SSH_PRIVATE_KEY"
FIRSTBOOT_SRC="$repo_root/solution/image-builder/files/fl-gold-firstboot.sh"
[[ -f "$FIRSTBOOT_SRC" ]] || die "Missing $FIRSTBOOT_SRC"

POC_ID="${1:-}"
BUILDER_ID="${2:-}"
if [[ -z "$POC_ID" && -f "$out_dir/aws-outputs.json" ]]; then
  POC_ID=$(python3 -c "import json;print(json.load(open(r'''$out_dir/aws-outputs.json'''))['instance_id'])")
fi
if [[ -z "$BUILDER_ID" && -f "$out_dir/builder-outputs.json" ]]; then
  BUILDER_ID=$(python3 -c "import json;print(json.load(open(r'''$out_dir/builder-outputs.json''')).get('instance_id',''))" 2>/dev/null || true)
fi
if [[ -z "$BUILDER_ID" ]]; then
  BUILDER_ID=$(aws ec2 describe-instances \
    --filters Name=tag:Role,Values=image-builder Name=instance-state-name,Values=running \
    --query 'Reservations[0].Instances[0].InstanceId' --output text)
fi
[[ -n "$POC_ID" && "$POC_ID" != "None" ]] || die "PoC instance id unknown"
[[ -n "$BUILDER_ID" && "$BUILDER_ID" != "None" ]] || die "Builder instance id unknown — pass as arg 2"

BUILDER_IP=$(aws ec2 describe-instances --instance-ids "$BUILDER_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
[[ -n "$BUILDER_IP" && "$BUILDER_IP" != "None" ]] || die "Builder has no public IP"

ROOT_DEV=$(aws ec2 describe-instances --instance-ids "$POC_ID" \
  --query 'Reservations[0].Instances[0].RootDeviceName' --output text)
VOL=$(aws ec2 describe-instances --instance-ids "$POC_ID" \
  --query "Reservations[0].Instances[0].BlockDeviceMappings[?DeviceName=='$ROOT_DEV'].Ebs.VolumeId | [0]" \
  --output text)
AZ=$(aws ec2 describe-instances --instance-ids "$BUILDER_ID" \
  --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)
POC_AZ=$(aws ec2 describe-instances --instance-ids "$POC_ID" \
  --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)

echo "[patch] PoC=$POC_ID vol=$VOL builder=$BUILDER_ID ($BUILDER_IP) AZ=$AZ"
[[ "$AZ" == "$POC_AZ" ]] || die "PoC AZ $POC_AZ != builder AZ $AZ — volumes must be same AZ"

echo "[patch] Stopping PoC..."
aws ec2 stop-instances --instance-ids "$POC_ID" >/dev/null
aws ec2 wait instance-stopped --instance-ids "$POC_ID"

echo "[patch] Detaching $VOL..."
aws ec2 detach-volume --volume-id "$VOL" >/dev/null
aws ec2 wait volume-available --volume-ids "$VOL"

ATTACH_DEV=/dev/sdf
echo "[patch] Attaching $VOL to builder as $ATTACH_DEV..."
aws ec2 attach-volume --volume-id "$VOL" --instance-id "$BUILDER_ID" --device "$ATTACH_DEV" >/dev/null
aws ec2 wait volume-in-use --volume-ids "$VOL"
sleep 5

echo "[patch] Copying firstboot + patching on builder..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i "$KEY" "$FIRSTBOOT_SRC" "${SSH_USER}@${BUILDER_IP}:/tmp/fl-gold-firstboot.sh"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i "$KEY" "${SSH_USER}@${BUILDER_IP}" \
  "sudo bash -s" <<'EOS'
set -euo pipefail
# Find the attached disk (nvme or sdf)
DEV=""
for c in /dev/nvme1n1 /dev/nvme2n1 /dev/xvdf /dev/sdf; do
  if [[ -b "$c" ]]; then DEV="$c"; break; fi
done
# Prefer newest nvme that is NOT the builder root
if [[ -z "$DEV" ]]; then
  DEV=$(lsblk -nd -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}' | tail -1)
fi
[[ -n "$DEV" ]] || { echo "No attached disk found"; lsblk; exit 1; }
echo "Using disk $DEV"
MNT=/mnt/poc-root
mkdir -p "$MNT"
# Try root LV via LVM, else first partition
if file -s "$DEV"* 2>/dev/null | grep -qi LVM || pvs 2>/dev/null | grep -q "$DEV"; then
  vgchange -ay || true
  # common Image Builder root LV name
  if [[ -e /dev/rootvg/rootlv ]]; then
    mount /dev/rootvg/rootlv "$MNT"
  else
    LV=$(lvs --noheadings -o lv_path 2>/dev/null | awk '{print $1}' | head -1)
    mount "$LV" "$MNT"
  fi
else
  PART="${DEV}p1"
  [[ -b "$PART" ]] || PART="${DEV}1"
  mount "$PART" "$MNT"
fi
echo "Mounted at $MNT"
install -d -m 0755 "$MNT/etc/fl-gold/bin" "$MNT/etc/sudoers.d"
cp /tmp/fl-gold-firstboot.sh "$MNT/etc/fl-gold/bin/fl-gold-firstboot.sh"
chmod 0755 "$MNT/etc/fl-gold/bin/fl-gold-firstboot.sh"
cat >"$MNT/etc/sudoers.d/99-fl-poc-nopasswd" <<'S'
fladmin1 ALL=(ALL) NOPASSWD:ALL
S
chmod 0440 "$MNT/etc/sudoers.d/99-fl-poc-nopasswd"
# validate sudoers if chroot possible
rm -f "$MNT/var/lib/fl-gold-firstboot-done"
# enable oneshot on next boot via flag
mkdir -p "$MNT/var/lib/cloud/scripts/per-boot"
cat >"$MNT/var/lib/fl-gold-run-firstboot" <<'F'
run
F
# Drop a systemd oneshot trigger via rc.local-like
cat >"$MNT/etc/systemd/system/fl-gold-firstboot.service" <<'U'
[Unit]
Description=Fedora Lane gold image firstboot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/etc/fl-gold/bin/fl-gold-firstboot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
U
# ensure enabled
mkdir -p "$MNT/etc/systemd/system/multi-user.target.wants"
ln -sf /etc/systemd/system/fl-gold-firstboot.service \
  "$MNT/etc/systemd/system/multi-user.target.wants/fl-gold-firstboot.service" || true
sync
umount "$MNT"
vgchange -an rootvg 2>/dev/null || true
echo "Patch complete"
EOS

echo "[patch] Detaching from builder..."
aws ec2 detach-volume --volume-id "$VOL" >/dev/null
aws ec2 wait volume-available --volume-ids "$VOL"

echo "[patch] Re-attaching to PoC as $ROOT_DEV..."
aws ec2 attach-volume --volume-id "$VOL" --instance-id "$POC_ID" --device "$ROOT_DEV" >/dev/null
aws ec2 wait volume-in-use --volume-ids "$VOL"

echo "[patch] Starting PoC..."
aws ec2 start-instances --instance-ids "$POC_ID" >/dev/null
aws ec2 wait instance-running --instance-ids "$POC_ID"
sleep 5
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$POC_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

python3 - <<PY
import json
from pathlib import Path
p = Path(r"""$out_dir/aws-outputs.json""")
data = json.loads(p.read_text())
data["public_ip"] = "$PUBLIC_IP"
data["instance_id"] = "$POC_ID"
data["ssh_gold"] = f"ssh -i $SSH_PRIVATE_KEY -p 2222 fladmin1@$PUBLIC_IP"
data["httpd"] = f"http://$PUBLIC_IP:35443/"
p.write_text(json.dumps(data, indent=2) + "\n")
print("Updated aws-outputs.json")
PY

echo
echo "Patched. Wait ~3 min for boot + firstboot, then:"
echo "  ./verify-remote.sh"
echo "  IP=$PUBLIC_IP"
