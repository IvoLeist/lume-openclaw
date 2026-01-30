#!/usr/bin/env bash
#
# Start the Lume VM (if not already running), wait until SSH is available,
# then run the OpenClaw gateway in this terminal.
# Use another terminal for the TUI (./scripts/openclaw/tui.sh) or SSH.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (default: geegz)
#
# Usage:
#   ./scripts/vm/launch-vm-and-gateway.sh
#   VM_USER=myuser ./scripts/vm/launch-vm-and-gateway.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VM_NAME="${VM_NAME:-openclaw}"
VM_USER="${VM_USER:-geegz}"

if ! command -v lume &>/dev/null; then
  echo "Lume is not installed. Run ./scripts/vm/install-lume.sh first."
  exit 1
fi

get_ip() {
  lume get "$VM_NAME" 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1 || true
}

ssh_ok() {
  local ip="$1"
  ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=3 -o BatchMode=yes "$VM_USER@$ip" "true" 2>/dev/null
}

IP=$(get_ip)

if [[ -z "$IP" ]]; then
  echo "VM not running. Starting VM '$VM_NAME' headlessly in background..."
  ( lume run "$VM_NAME" --no-display ) &
  LUME_PID=$!
  echo "Waiting for VM to boot and get an IP (up to ~120s)..."
  for _ in {1..60}; do
    sleep 2
    IP=$(get_ip)
    [[ -n "$IP" ]] && break
  done
  if [[ -z "$IP" ]]; then
    echo "Could not get VM IP. Check Lume and try again."
    kill $LUME_PID 2>/dev/null || true
    exit 1
  fi
  echo "VM IP: $IP. Waiting for SSH (up to ~60s)..."
  for _ in {1..30}; do
    sleep 2
    if ssh_ok "$IP"; then
      break
    fi
  done
  if ! ssh_ok "$IP"; then
    echo "SSH not ready. You can try again in a minute: ./scripts/openclaw/openclaw-gateway.sh"
    exit 1
  fi
else
  echo "VM already running at $IP."
fi

echo "Starting OpenClaw gateway (Ctrl+C to stop gateway; VM keeps running)..."
exec "$REPO_ROOT/scripts/openclaw/openclaw-gateway.sh"
