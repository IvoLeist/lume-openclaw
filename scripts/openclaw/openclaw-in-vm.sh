#!/usr/bin/env bash
#
# SSH into the Lume VM and run a command.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (default: geegz; override if your VM user is different)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   ./scripts/openclaw/openclaw-in-vm.sh                    # default: openclaw status
#   ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"
#   VM_USER=lume ./scripts/openclaw/openclaw-in-vm.sh "npm install -g openclaw@latest && openclaw onboard --install-daemon"
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"
VM_USER="${VM_USER:-geegz}"
CMD="${1:-openclaw status}"

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

# Non-interactive SSH does not source ~/.zshrc; ensure npm global bin (openclaw) is on PATH.
# Pass CMD via base64 to avoid quoting issues with special characters.
B64_CMD=$(printf '%s' "$CMD" | base64 | tr -d '\n')
ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP" \
  "export PATH=\"\$HOME/node-v22.12.0-darwin-arm64/bin:\$PATH\" && bash -c \"\$(echo $B64_CMD | base64 -d)\""
