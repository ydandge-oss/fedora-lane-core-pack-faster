#!/bin/bash
# Build local httpd image and ensure firewall zone on first boot of Image Mode system.
set -euo pipefail

MARKER=/var/lib/fl-gold-firstboot-done
if [[ -f "$MARKER" ]]; then
  exit 0
fi

# Prefer fl-gold firewall zone
if systemctl is-active --quiet firewalld; then
  firewall-cmd --set-default-zone=fl-gold || true
  firewall-cmd --permanent --zone=fl-gold --add-port=2222/tcp || true
  firewall-cmd --permanent --zone=fl-gold --add-port=35443/tcp || true
  firewall-cmd --reload || true
fi

# Build httpd app image from UBI if not present
if ! podman image exists localhost/fl-httpd-gold:latest; then
  TMP=$(mktemp -d)
  cat >"$TMP/Containerfile" <<'EOF'
FROM registry.access.redhat.com/ubi9/httpd-24
COPY html/ /var/www/html/
EOF
  mkdir -p "$TMP/html"
  cp -a /opt/fl/httpd-gold/html/. "$TMP/html/"
  podman build -t localhost/fl-httpd-gold:latest "$TMP"
  rm -rf "$TMP"
fi

systemctl daemon-reload || true
systemctl enable --now fl-httpd.service 2>/dev/null || \
  podman run -d --name fl-httpd --replace -p 35443:8080 \
    -v /opt/fl/httpd-gold/html:/var/www/html:Z localhost/fl-httpd-gold:latest

touch "$MARKER"
