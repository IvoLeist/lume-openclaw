#!/usr/bin/env bash
#
# Start the Lume VM with VNC display (desktop UI).
# Wrapper around start-vm.sh with LUME_DISPLAY=1.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#
# Usage:
#   ./scripts/vm/start-vm-with-display.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LUME_DISPLAY=1
exec "$SCRIPT_DIR/start-vm.sh"
