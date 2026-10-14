#!/usr/bin/env bash
# Fedora Lane — RHEL Golden Image Proof of Concept runner
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
POC="$ROOT/poc"
OUT="$POC/output"
MODE="local"
CLEANUP_ONLY=0
API_PID=""
CONTAINER_NAME="fl-rhel-baseline-poc"

log() { echo "[poc] $*" | tee -a "$OUT/poc.log"; }

usage() {
  cat <<EOF
Usage: ./poc/run-poc.sh [--local|--container] [--cleanup]

  --local       Laptop PoC with uvicorn (default)
  --container   UBI9 stand-in via Podman
  --cleanup     Stop API / remove PoC container
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) MODE="local"; shift ;;
    --container) MODE="container"; shift ;;
    --cleanup) CLEANUP_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

mkdir -p "$OUT"
: > "$OUT/poc.log"

cleanup() {
  if [[ -n "${API_PID}" ]] && kill -0 "$API_PID" 2>/dev/null; then
    kill "$API_PID" 2>/dev/null || true
    wait "$API_PID" 2>/dev/null || true
  fi
  if command -v podman >/dev/null 2>&1; then
    podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  fi
  # Also clear local uvicorn if we tracked a pidfile
  if [[ -f "$OUT/uvicorn.pid" ]]; then
    kill "$(cat "$OUT/uvicorn.pid")" 2>/dev/null || true
    rm -f "$OUT/uvicorn.pid"
  fi
}

if [[ "$CLEANUP_ONLY" -eq 1 ]]; then
  cleanup
  echo "Cleanup complete."
  exit 0
fi

trap cleanup EXIT

log "Root: $ROOT"
log "Mode: $MODE"

# --- 1. Validate blueprint ---
log "Step 1/5 — Validate Image Builder blueprint"
bash "$ROOT/solution/scripts/validate-blueprint.sh" | tee -a "$OUT/poc.log"

# --- 2. Snowflake vs baseline ---
log "Step 2/5 — Compare snowflake vs baseline profiles"
python3 "$POC/lib/compare_profiles.py" | tee -a "$OUT/poc.log"

# --- 3. Simulated Insights ---
log "Step 3/5 — Simulate Insights registration evidence"
python3 "$POC/lib/simulate_insights.py" | tee -a "$OUT/poc.log"

# --- 4. Working deployment ---
log "Step 4/5 — Start Boutique Inventory Sync on baseline runtime"
HEALTH_JSON=""

if [[ "$MODE" == "container" ]]; then
  if ! command -v podman >/dev/null 2>&1; then
    log "ERROR: podman not found. Use --local or install Podman."
    exit 1
  fi
  if ! podman info >/dev/null 2>&1; then
    log "ERROR: Podman is not running. Try: podman machine start"
    exit 1
  fi
  log "Building UBI baseline stand-in image..."
  podman build -f "$POC/Containerfile" -t fl-rhel-baseline-poc:latest "$ROOT" | tee -a "$OUT/poc.log"
  podman rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  podman run -d --name "$CONTAINER_NAME" -p 8080:8080 fl-rhel-baseline-poc:latest | tee -a "$OUT/poc.log"
  for i in $(seq 1 30); do
    if HEALTH_JSON=$(curl -sf http://127.0.0.1:8080/health); then
      break
    fi
    sleep 1
  done
else
  # Use /tmp for venv so sandbox / sync tools don't break include/ symlinks
  VENV="${FL_POC_VENV:-/tmp/fedora-lane-poc-venv}"
  if [[ ! -x "$VENV/bin/uvicorn" ]]; then
    python3 -m venv "$VENV"
    # shellcheck disable=SC1091
    source "$VENV/bin/activate"
    pip install -q -r "$ROOT/solution/inventory-sync/requirements.txt"
  else
    # shellcheck disable=SC1091
    source "$VENV/bin/activate"
  fi
  export SYNC_API_TOKEN=demo-not-a-real-secret
  export FL_ENV=poc-local
  (
    cd "$ROOT/solution/inventory-sync"
    "$VENV/bin/uvicorn" app.main:app --host 127.0.0.1 --port 8080
  ) >>"$OUT/poc.log" 2>&1 &
  API_PID=$!
  echo "$API_PID" > "$OUT/uvicorn.pid"
  for i in $(seq 1 30); do
    if HEALTH_JSON=$(curl -sf http://127.0.0.1:8080/health); then
      break
    fi
    sleep 1
  done
fi

if [[ -z "${HEALTH_JSON}" ]]; then
  log "ERROR: API did not become healthy on :8080"
  exit 1
fi

log "Health: $HEALTH_JSON"
STATUS_JSON=$(curl -sf http://127.0.0.1:8080/api/v1/sync/status)
log "Sync status: $STATUS_JSON"
SYNC_JSON=$(curl -sf -X POST http://127.0.0.1:8080/api/v1/sync/run -H "X-Api-Token: demo-not-a-real-secret")
log "Sync run: $SYNC_JSON"

# --- 5. Evidence pack ---
log "Step 5/5 — Write evidence report"
python3 "$POC/lib/write_evidence.py" "$MODE" "$HEALTH_JSON" | tee -a "$OUT/poc.log"

echo
echo "============================================================"
echo " PoC SUCCESS — show this in your presentation:"
echo "   $OUT/evidence-report.md"
echo "============================================================"
echo
cat "$OUT/evidence-report.md"

# Keep API up for interactive demo unless FL_POC_KEEP=0
if [[ "${FL_POC_KEEP:-1}" == "1" ]]; then
  trap - EXIT
  echo
  echo "API still running on http://127.0.0.1:8080 for live demo."
  echo "Stop with: ./poc/run-poc.sh --cleanup"
fi
