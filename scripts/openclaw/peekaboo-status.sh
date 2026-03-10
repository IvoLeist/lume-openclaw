#!/usr/bin/env bash
#
# SSH into the Lume VM and run peekaboo bridge status (verbose).
# Use this to verify Peekaboo Bridge is running inside the VM.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username in the VM (required; same as openclaw-in-vm.sh)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   VM_USER=youruser ./scripts/openclaw/peekaboo-status.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${VM_USER:-}" ]]; then
  echo "VM_USER is required (SSH username in the VM). Example: VM_USER=youruser $0"
  exit 1
fi

exec "$SCRIPT_DIR/openclaw-in-vm.sh" 'peekaboo bridge status --verbose'
