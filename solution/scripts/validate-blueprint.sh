#!/usr/bin/env bash
# Lightweight local validation — does not require osbuild-composer.
set -euo pipefail

BP="$(cd "$(dirname "$0")/../image-builder" && pwd)/fl-rhel-baseline.toml"

echo "Validating blueprint: $BP"

grep -q '^name = "fl-rhel-baseline"' "$BP"
grep -q 'insights-client' "$BP"
grep -q 'chrony' "$BP"
grep -q '\[customizations.timezone\]' "$BP"
grep -q 'AAAAREPLACE_WITH_YOUR_PUBLIC_KEY' "$BP" && echo "NOTE: replace SSH public key placeholder before real compose"

echo "Blueprint basic checks passed."
