#!/usr/bin/env bash
#
# Open an interactive SSH session to the Lume VM.
# Uses the same VM name and IP resolution as openclaw-in-vm.sh.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username in the VM (required)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   VM_USER=youruser ./scripts/connect/ssh-vm.sh
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"

if [[ -z "${VM_USER:-}" ]]; then
  echo "VM_USER is required (SSH username in the VM). Example: VM_USER=youruser $0"
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

echo "Connecting to $VM_USER@$IP (VM: $VM_NAME)..."
exec ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP"
