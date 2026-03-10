#!/usr/bin/env bash
#
# SSH into the Lume VM and run a command.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username in the VM (required)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh
#   VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"
#   VM_USER=lume ./scripts/openclaw/openclaw-in-vm.sh "npm install -g openclaw@latest && openclaw onboard --install-daemon"
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./remote-env.lib.sh
source "$SCRIPT_DIR/remote-env.lib.sh"

VM_NAME="${VM_NAME:-openclaw}"
CMD="${1:-openclaw status}"

if [[ -z "${VM_USER:-}" ]]; then
  echo "VM_USER is required (SSH username in the VM). Example: VM_USER=youruser $0 \"openclaw status\""
  exit 1
fi

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

B64_CMD=$(printf '%s' "$CMD" | base64 | tr -d '\n')
exec ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP" 'bash -s' <<EOF
set -euo pipefail
$(remote_env_prelude)
CMD_B64='$B64_CMD'
bash -lc "\$(printf '%s' "\$CMD_B64" | base64 -d)"
EOF
