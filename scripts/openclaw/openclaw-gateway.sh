#!/usr/bin/env bash
#
# SSH into the Lume VM and run OpenClaw gateway only (for Telegram, WhatsApp, etc.).
# Ensures the gateway LaunchAgent has PATH with ~/bin (peekaboo) and Node bin, then
# starts gateway or tails logs if the daemon is already running.
# Leave this running; use another terminal for other commands.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (default: geegz)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#
# Usage:
#   ./scripts/openclaw/openclaw-gateway.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_NAME="${VM_NAME:-openclaw}"
VM_USER="${VM_USER:-geegz}"
export VM_USER

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

# Ensure gateway LaunchAgent PATH includes ~/bin (peekaboo) and Node bin (idempotent).
PATCH_SCRIPT=$(cat << 'PATCH_END'
set -euo pipefail
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST=""
for f in "$PLIST_DIR"/*.plist; do
  [[ -f "$f" ]] || continue
  if grep -q -i "openclaw\|gateway\|claw" "$f" 2>/dev/null; then
    PLIST="$f"
    break
  fi
done
if [[ -n "$PLIST" ]]; then
  PATH_VAL="$HOME/bin:$HOME/node-v22.12.0-darwin-arm64/bin:/usr/local/bin:/usr/bin:/bin"
  if ! /usr/libexec/PlistBuddy -c "Print :EnvironmentVariables" "$PLIST" 2>/dev/null; then
    /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables dict" "$PLIST"
  fi
  /usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:PATH string $PATH_VAL" "$PLIST" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Set :EnvironmentVariables:PATH $PATH_VAL" "$PLIST"
  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load "$PLIST"
fi
PATCH_END
)
"$SCRIPT_DIR/openclaw-in-vm.sh" "$PATCH_SCRIPT" >/dev/null 2>&1 || true

echo "Starting OpenClaw gateway on $VM_NAME ($VM_USER@$IP)..."
# If the gateway daemon is already running in the VM, "openclaw gateway" would fail (port in use).
# Then we just tail logs so the session stays useful; otherwise run gateway in foreground.
exec ssh -t -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP" \
  'export PATH="$HOME/node-v22.12.0-darwin-arm64/bin:$PATH" && if openclaw status 2>/dev/null | grep -q "running (pid"; then echo ""; echo "Gateway already running in VM (LaunchAgent). Tailing logs — Ctrl+C to stop."; echo ""; openclaw logs --follow; else openclaw gateway; fi'
