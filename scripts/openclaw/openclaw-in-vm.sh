#!/usr/bin/env bash
#
# SSH into the Lume VM and run a command.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (required; e.g. your macOS account in the VM, or "lume" if using unattended tahoe)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   VM_USER=myuser ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"
#   VM_USER=lume ./scripts/openclaw/openclaw-in-vm.sh "npm install -g openclaw@latest && openclaw onboard --install-daemon"
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"
CMD="${1:-}"

if [[ -z "${VM_USER:-}" ]]; then
  echo "VM_USER is required (SSH username in the VM). Example: VM_USER=myuser $0 'openclaw status'"
  exit 1
fi

if [[ -z "$CMD" ]]; then
  echo "Usage: VM_USER=user $0 '<command>'"
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

ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP" "$CMD"
