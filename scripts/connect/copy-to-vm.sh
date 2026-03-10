#!/usr/bin/env bash
#
# Copy a file or directory from the host to the Lume VM over SSH (scp).
# Uses the same VM name and IP resolution as ssh-vm.sh and openclaw-in-vm.sh.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (required; for example your VM account or `lume`)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   VM_USER=myuser ./scripts/connect/copy-to-vm.sh /path/to/file.dmg ~/Downloads/
#   VM_USER=myuser ./scripts/connect/copy-to-vm.sh ./OpenClaw.dmg '~/Downloads/'
# Use single quotes for remote paths with ~ so they are expanded on the VM, not the host.
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"
LOCAL_PATH="${1:-}"
REMOTE_PATH="${2:-}"

if [[ -z "${VM_USER:-}" ]]; then
  echo "VM_USER is required (SSH username in the VM). Example: VM_USER=myuser $0 ./file.dmg ~/Downloads/"
  exit 1
fi

if [[ -z "$LOCAL_PATH" || -z "$REMOTE_PATH" ]]; then
  echo "Usage: VM_USER=user $0 <local_path> <remote_path>"
  echo "Example: VM_USER=myuser $0 ./App.dmg ~/Downloads/"
  exit 1
fi

if [[ ! -e "$LOCAL_PATH" ]]; then
  echo "Local path does not exist: $LOCAL_PATH"
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

SCP_OPTS=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10)
if [[ -d "$LOCAL_PATH" ]]; then
  SCP_OPTS=(-r "${SCP_OPTS[@]}")
fi
echo "Copying $LOCAL_PATH -> $VM_USER@$IP:$REMOTE_PATH (VM: $VM_NAME)..."
exec scp "${SCP_OPTS[@]}" "$LOCAL_PATH" "$VM_USER@$IP:$REMOTE_PATH"
