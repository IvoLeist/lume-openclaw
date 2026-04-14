#!/usr/bin/env bash
#
# Create the Lume macOS VM for OpenClaw (default name: openclaw).
# Optional: use --unattended tahoe for automated Setup Assistant (user lume / pass lume; change after first login).
#
# Env:
#   VM_NAME     - VM name (default: openclaw)
#   UNATTENDED  - set to "tahoe" for unattended setup; leave unset for manual Setup Assistant
#   IPSW        - path or "latest" (default: latest)
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"
UNATTENDED="${UNATTENDED:-}"
IPSW="${IPSW:-latest}"

if ! command -v lume &>/dev/null; then
  echo "Lume is not installed. Run ./scripts/vm/install-lume.sh first."
  exit 1
fi

if lume get "$VM_NAME" &>/dev/null; then
  echo "VM '$VM_NAME' already exists. Use 'lume delete $VM_NAME' first to recreate."
  exit 1
fi

echo "Creating VM '$VM_NAME' (ipsw=$IPSW)..."
if [[ -n "$UNATTENDED" ]]; then
  echo "Using unattended preset: $UNATTENDED (user lume / pass lume; change after first login)."
  lume create "$VM_NAME" --os macos --ipsw "$IPSW" --unattended "$UNATTENDED"
else
  lume create "$VM_NAME" --os macos --ipsw "$IPSW" --storage external --memory 6GB --cpu 3
  echo "VNC window will open. Complete Setup Assistant, then enable Remote Login (System Settings → Sharing)."
fi

echo "VM '$VM_NAME' created. Get IP with: lume get $VM_NAME"
