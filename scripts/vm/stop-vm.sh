#!/usr/bin/env bash
#
# Stop the Lume VM.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"

if ! command -v lume &>/dev/null; then
  echo "Lume is not installed. Run ./scripts/vm/install-lume.sh first."
  exit 1
fi

echo "Stopping VM '$VM_NAME'..."
lume stop "$VM_NAME"
