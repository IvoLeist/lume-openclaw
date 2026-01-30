#!/usr/bin/env bash
#
# Start the Lume VM headlessly (no VNC window).
# Set LUME_DISPLAY=1 to start with display.
#
# Env:
#   VM_NAME     - VM name (default: openclaw)
#   LUME_DISPLAY - set to 1 to open VNC window; unset for headless
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"

if ! command -v lume &>/dev/null; then
  echo "Lume is not installed. Run ./scripts/vm/install-lume.sh first."
  exit 1
fi

if [[ "${LUME_DISPLAY:-}" == "1" ]]; then
  echo "Starting VM '$VM_NAME' with display..."
  lume run "$VM_NAME"
else
  echo "Starting VM '$VM_NAME' headlessly..."
  lume run "$VM_NAME" --no-display
fi
