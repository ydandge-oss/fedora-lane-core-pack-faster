#!/usr/bin/env bash
# Apply Expansion Pack hardening on a running RHEL VM if Kickstart was not used.
# Run as root on the gold-image builder VM BEFORE exporting the image.
set -euo pipefail

echo "[fl-gold] Applying runtime hardening..."

# Partitions: document-only reminder (must exist from install)
for m in /var/log /home /tmp /var/tmp; do
  findmnt -n "$m" >/dev/null || echo "WARN: $m is not a separate mount — fix disk layout before export"
done
findmnt -n -o OPTIONS /tmp | grep -q noexec || echo "WARN: /tmp missing noexec"

getenforce | grep -qi Enforcing || setenforce 1
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

groupadd -f fladmins
id fladmin1 >/dev/null 2>&1 || useradd -m -G fladmins,wheel fladmin1
id fladmin2 >/dev/null 2>&1 || useradd -m -G fladmins,wheel fladmin2

cat >/etc/sudoers.d/fladmins <<'EOF'
Defaults:%fladmins timestamp_timeout=0
%fladmins ALL=(ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/fladmins

mkdir -p /etc/ssh/sshd_config.d
cat >/etc/ssh/sshd_config.d/00-fl-gold.conf <<'EOF'
Port 2222
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AllowGroups fladmins
EOF

semanage port -a -t ssh_port_t -p tcp 2222 2>/dev/null || semanage port -m -t ssh_port_t -p tcp 2222
semanage port -a -t http_port_t -p tcp 35443 2>/dev/null || semanage port -m -t http_port_t -p tcp 35443

systemctl enable --now firewalld
firewall-cmd --permanent --remove-service=ssh || true
firewall-cmd --permanent --add-port=2222/tcp
firewall-cmd --permanent --add-port=35443/tcp
firewall-cmd --reload

systemctl enable sshd
systemctl restart sshd

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
mkdir -p /opt/fl/httpd-gold
cp -a "$ROOT/container/." /opt/fl/httpd-gold/
cd /opt/fl/httpd-gold
podman build -t localhost/fl-httpd-gold:latest .
mkdir -p /etc/containers/systemd
cp "$ROOT/systemd/fl-httpd.container" /etc/containers/systemd/
systemctl daemon-reload
systemctl enable --now fl-httpd.service || \
  podman run -d --name fl-httpd --replace -p 35443:8080 \
    -v /opt/fl/httpd-gold/html:/var/www/html:Z localhost/fl-httpd-gold:latest

mkdir -p /etc/fl-gold
cat >/etc/fl-gold/MARKER <<'EOF'
Fedora Lane RHEL Gold Image — Server/Cloud OS Expansion Pack
SSH: 2222 | httpd container: 35443 | SELinux: enforcing
EOF

echo "[fl-gold] Done. Run verify-gold-image.sh next."
