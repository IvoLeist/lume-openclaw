#!/usr/bin/env bash
#
# Stop the OpenClaw gateway/daemon in the Lume VM.
# Use this before relaunching the gateway (e.g. npm run gateway).
#
# Env: VM_NAME, VM_USER, VM_IP (same as openclaw-in-vm.sh)
#
# Usage:
#   ./scripts/openclaw/openclaw-stop.sh
#
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec "$SCRIPT_DIR/openclaw-in-vm.sh" "openclaw gateway stop"
