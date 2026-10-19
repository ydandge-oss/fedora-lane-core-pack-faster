#version=RHEL9
# Fedora Lane — Server/Cloud OS Expansion Pack gold image (MANUAL build)
# Do NOT use hosted Image Builder. Build with virt-install / local composer / bare-metal kickstart.
#
# BEFORE BUILD:
#   1. Replace YOUR_ORG / activation-key placeholders OR use a subscribed builder ISO method
#   2. Replace SSH public key
#   3. Set strong passwords (openssl passwd -6) for fladmin1/fladmin2 — do not commit real hashes to public forks
#
# Disk layout (each of /var/log /home /tmp /var/tmp under 5 GiB as required)

text
reboot
cdrom
# Or: url --url="http://..." for network install

lang en_US.UTF-8
keyboard us
timezone UTC --utc
network --bootproto=dhcp --device=link --activate --hostname=fl-rhel-gold

# Subscription — use RHDP/subscribed method appropriate to your lab. Do not commit real keys.
# rhsm --organization=YOUR_ORG --activation-key=YOUR_KEY

# Lock root password login; admins use sudo. Set a locked random root or known lab-only hash offline.
rootpw --lock

# Firewall: only SSH (2222) and httpd (35443) — applied again in %post for certainty
firewall --disabled
selinux --enforcing
services --enabled=sshd,firewalld,chronyd,podman

# ---- Partitioning (biosboot/efi adjust for target; this example is BIOS/UEFI-generic lab) ----
# Total disk suggestion for gold image: >= 30 GiB
ignoredisk --only-use=vda
zerombr
clearpart --all --initlabel --drives=vda
reqpart
part /boot --fstype=xfs --size=1024
part pv.01 --size=1 --grow
volgroup vg_fl pv.01
logvol / --fstype=xfs --name=root --vgname=vg_fl --size=12288
logvol swap --name=swap --vgname=vg_fl --size=2048
# Expansion Pack required separate mounts — each under 5 GiB
logvol /var/log --fstype=xfs --name=varlog --vgname=vg_fl --size=4096
logvol /home --fstype=xfs --name=home --vgname=vg_fl --size=4096
logvol /tmp --fstype=xfs --name=tmp --vgname=vg_fl --size=2048 --fsoptions="defaults,nodev,nosuid,noexec"
logvol /var/tmp --fstype=xfs --name=vartmp --vgname=vg_fl --size=2048 --fsoptions="defaults,nodev,nosuid,noexec"

%packages
@^minimal-environment
@standard
kernel
firewalld
policycoreutils-python-utils
setools-console
audit
chrony
sudo
vim-enhanced
curl
jq
podman
container-tools
httpd-tools
# Optional stretch later:
# openscap-scanner
# scap-security-guide
%end

%post --log=/root/ks-fl-gold-post.log
set -euo pipefail

echo "=== Fedora Lane gold image %post start ==="

# --- Admin group + users (sudo with password always required) ---
groupadd -f fladmins
# Create admins. Set passwords AFTER install (do not commit real hashes):
#   openssl passwd -6 'YourStrongPassword'
#   echo 'fladmin1:$6$...' | chpasswd -e
useradd -m -G fladmins,wheel fladmin1 || true
useradd -m -G fladmins,wheel fladmin2 || true
passwd -d fladmin1 || true
passwd -d fladmin2 || true
chage -d 0 fladmin1 || true
chage -d 0 fladmin2 || true
echo "WARN: set fladmin passwords before cloud export — see docs/poc-steps.md"

mkdir -p /etc/sudoers.d
cat >/etc/sudoers.d/fladmins <<'EOF'
# Fedora Lane — admins may sudo to root but MUST authenticate every time
Defaults:%fladmins timestamp_timeout=0
Defaults:%fladmins !authenticate_env
%fladmins ALL=(ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/fladmins
# Ensure no NOPASSWD for wheel
sed -i 's/^%wheel\s\+ALL=(ALL)\s\+NOPASSWD: ALL/# &/' /etc/sudoers || true
echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel-password
chmod 0440 /etc/sudoers.d/wheel-password

# --- SSH on 2222; harden ---
mkdir -p /etc/ssh/sshd_config.d
cat >/etc/ssh/sshd_config.d/00-fl-gold.conf <<'EOF'
Port 2222
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
X11Forwarding no
AllowGroups fladmins
EOF

# SELinux port for SSH
if command -v semanage >/dev/null 2>&1; then
  semanage port -a -t ssh_port_t -p tcp 2222 || semanage port -m -t ssh_port_t -p tcp 2222 || true
fi

# Admin authorized_keys placeholder — REPLACE with real public keys before imaging
for u in fladmin1 fladmin2; do
  mkdir -p /home/$u/.ssh
  chmod 700 /home/$u/.ssh
  cat >/home/$u/.ssh/authorized_keys <<'EOF'
ssh-ed25519 AAAAREPLACE_WITH_REAL_PUBLIC_KEY fladmin@fedorlane-gold
EOF
  chmod 600 /home/$u/.ssh/authorized_keys
  chown -R $u:$u /home/$u/.ssh
done

# --- Firewall: only 2222 and 35443 ---
systemctl enable firewalld
firewall-offline-cmd --set-default-zone=public || true
firewall-offline-cmd --remove-service=ssh || true
firewall-offline-cmd --add-port=2222/tcp || true
firewall-offline-cmd --add-port=35443/tcp || true

# --- httpd in container on 35443 ---
mkdir -p /opt/fl/httpd-gold/html /etc/fl-gold
cat >/opt/fl/httpd-gold/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Fedora Lane Gold Image</title></head>
<body>
  <h1>Fedora Lane e-commerce web baseline</h1>
  <p>httpd is running from the RHEL gold image container.</p>
  <p>Server/Cloud OS TDP — standardized, SELinux enforcing, port 35443.</p>
</body>
</html>
EOF

cat >/opt/fl/httpd-gold/Containerfile <<'EOF'
FROM registry.access.redhat.com/ubi9/httpd-24
COPY html/ /var/www/html/
EOF

# SELinux port for httpd container publish
if command -v semanage >/dev/null 2>&1; then
  semanage port -a -t http_port_t -p tcp 35443 || semanage port -m -t http_port_t -p tcp 35443 || true
fi

# Quadlet / systemd unit for Podman (starts at boot)
mkdir -p /etc/containers/systemd
cat >/etc/containers/systemd/fl-httpd.container <<'EOF'
[Unit]
Description=Fedora Lane gold-image httpd (container)
After=network-online.target
Wants=network-online.target

[Container]
Image=localhost/fl-httpd-gold:latest
PublishPort=35443:8080
Volume=/opt/fl/httpd-gold/html:/var/www/html:Z
Environment=CONTAINER_NAME=fl-httpd

[Service]
Restart=always

[Install]
WantedBy=default.target
EOF

# First-boot script builds image if missing and ensures mounts
cat >/usr/local/sbin/fl-gold-firstboot.sh <<'EOF'
#!/bin/bash
set -euo pipefail
# Ensure /tmp noexec survives (fstab)
if ! grep -q ' /tmp ' /etc/fstab || ! grep -q 'noexec' /etc/fstab; then
  echo "WARN: verify /tmp noexec in /etc/fstab"
fi
if [[ ! -f /var/lib/fl-gold-image-built ]]; then
  cd /opt/fl/httpd-gold
  podman build -t localhost/fl-httpd-gold:latest .
  touch /var/lib/fl-gold-image-built
fi
systemctl daemon-reload || true
systemctl enable --now fl-httpd.service || podman run -d --name fl-httpd --replace \
  -p 35443:8080 -v /opt/fl/httpd-gold/html:/var/www/html:Z localhost/fl-httpd-gold:latest || true
EOF
chmod 755 /usr/local/sbin/fl-gold-firstboot.sh

cat >/etc/systemd/system/fl-gold-firstboot.service <<'EOF'
[Unit]
Description=Fedora Lane gold image firstboot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/fl-gold-firstboot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable fl-gold-firstboot.service
systemctl enable sshd firewalld chronyd

# Marker for demos
cat >/etc/fl-gold/MARKER <<'EOF'
Fedora Lane RHEL Gold Image — Server/Cloud OS Expansion Pack
SSH: 2222 | httpd container: 35443 | SELinux: enforcing | /tmp: noexec
EOF

echo "=== Fedora Lane gold image %post complete ==="
%end
