#!/usr/bin/env bash
#
# SSH into the Lume VM and run OpenClaw gateway only (for Telegram, WhatsApp, etc.).
# Leave this running; use another terminal for other commands.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (default: geegz)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   ./scripts/openclaw/openclaw-gateway.sh
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"
VM_USER="${VM_USER:-geegz}"

if ! command -v lume &>/dev/null; then
  echo "Lume is not installed. Run ./scripts/vm/install-lume.sh first."
  exit 1
fi

IP="${VM_IP:-}"
if [[ -z "$IP" ]]; then
  for _ in {1..30}; do
    IP=$(lume get "$VM_NAME" 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1 || true)
    [[ -n "$IP" ]] && break
    sleep 2
  done
fi

if [[ -z "$IP" ]]; then
  echo "Could not get VM IP. Is the VM running? Run: lume get $VM_NAME"
  exit 1
fi

echo "Starting OpenClaw gateway on $VM_NAME ($VM_USER@$IP)..."
exec ssh -t -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP" \
  'export PATH="$HOME/node-v22.12.0-darwin-arm64/bin:$PATH" && openclaw gateway'
