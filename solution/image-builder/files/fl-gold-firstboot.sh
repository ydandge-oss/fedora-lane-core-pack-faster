#!/bin/bash
# Fedora Lane — firstboot hardening for Image Builder gold image
# Baked into the image via blueprint [[customizations.files]]
set -uo pipefail

MARKER=/var/lib/fl-gold-firstboot-done
if [[ -f "$MARKER" ]]; then
  exit 0
fi

# SELinux enforcing
setenforce 1 || true
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config || true

# SELinux labels for Expansion Pack non-standard ports
if command -v semanage >/dev/null 2>&1; then
  semanage port -a -t ssh_port_t -p tcp 2222 2>/dev/null || semanage port -m -t ssh_port_t -p tcp 2222 || true
  semanage port -a -t http_port_t -p tcp 35443 2>/dev/null || semanage port -m -t http_port_t -p tcp 35443 || true
fi

# /tmp and /var/tmp noexec (blueprint minsize cannot set mount options)
if findmnt -n /tmp >/dev/null 2>&1; then
  mount -o remount,noexec,nodev,nosuid /tmp || true
  if grep -qE '[[:space:]]/tmp[[:space:]]' /etc/fstab; then
    awk '
      $2=="/tmp" && $4 !~ /noexec/ { $4="noexec,nodev,nosuid,"$4 }
      { print }
    ' /etc/fstab > /etc/fstab.fl && mv /etc/fstab.fl /etc/fstab
  fi
fi
if findmnt -n /var/tmp >/dev/null 2>&1; then
  mount -o remount,noexec,nodev,nosuid /var/tmp || true
fi

# Firewall: only 2222 + 35443
systemctl enable --now firewalld || true
firewall-cmd --permanent --remove-service=ssh || true
firewall-cmd --permanent --add-port=2222/tcp || true
firewall-cmd --permanent --add-port=35443/tcp || true
firewall-cmd --reload || true
systemctl enable --now sshd || true

# httpd in container on 35443
mkdir -p /opt/fl/httpd-gold/html
chmod 0755 /opt /opt/fl /opt/fl/httpd-gold /opt/fl/httpd-gold/html 2>/dev/null || true
rm -f /opt/fl/httpd-gold/html/index.html
umask 022
tee /opt/fl/httpd-gold/html/index.html >/dev/null <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Fedora Lane Gold Image</title></head>
<body>
  <h1>Fedora Lane e-commerce web baseline</h1>
  <p>httpd is running from a container on the RHEL Image Builder gold image.</p>
  <p>Port 35443 · SSH 2222 · SELinux enforcing</p>
</body>
</html>
HTML
chmod 0644 /opt/fl/httpd-gold/html/index.html

tee /opt/fl/httpd-gold/Containerfile >/dev/null <<'CF'
FROM registry.access.redhat.com/ubi9/httpd-24
COPY html/ /var/www/html/
CF

# Prefer registry image directly if local build is slow/unavailable
if ! podman image exists localhost/fl-httpd-gold:latest; then
  if (cd /opt/fl/httpd-gold && podman build -t localhost/fl-httpd-gold:latest .); then
    :
  else
    podman pull registry.access.redhat.com/ubi9/httpd-24 || true
    podman tag registry.access.redhat.com/ubi9/httpd-24 localhost/fl-httpd-gold:latest || true
  fi
fi

podman rm -f fl-httpd 2>/dev/null || true
podman run -d --name fl-httpd --restart=always \
  -p 35443:8080 \
  -v /opt/fl/httpd-gold/html:/var/www/html:Z \
  localhost/fl-httpd-gold:latest || \
podman run -d --name fl-httpd --restart=always \
  -p 35443:8080 \
  -v /opt/fl/httpd-gold/html:/var/www/html:Z \
  registry.access.redhat.com/ubi9/httpd-24 || true

cd /tmp
podman generate systemd --new --name fl-httpd --files --restart-policy=always 2>/dev/null || true
if [[ -f /tmp/container-fl-httpd.service ]]; then
  install -m 0644 /tmp/container-fl-httpd.service /etc/systemd/system/fl-httpd.service
  systemctl daemon-reload
  systemctl enable --now fl-httpd.service || true
fi

touch "$MARKER"
echo "Fedora Lane gold firstboot complete"
exit 0
