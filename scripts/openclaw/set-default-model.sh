#!/usr/bin/env bash
#
# Set the default OpenClaw model in the Lume VM and optionally restart the gateway.
# Also documents how to update the current session's model (e.g. webchat) so the
# UI shows the new model immediately.
#
# Env: VM_NAME, VM_USER, VM_IP (same as openclaw-in-vm.sh)
#
# Usage:
#   ./scripts/openclaw/set-default-model.sh [MODEL_ID]
#   ./scripts/openclaw/set-default-model.sh vercel-ai-gateway/anthropic/claude-haiku-4.5
#   VM_USER=youruser ./scripts/openclaw/set-default-model.sh
#
# Default MODEL_ID: vercel-ai-gateway/anthropic/claude-haiku-4.5 (Claude Haiku 4.5 via Vercel AI Gateway)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="${1:-vercel-ai-gateway/anthropic/claude-haiku-4.5}"

echo "Setting default model in VM to: $MODEL"
"$SCRIPT_DIR/openclaw-in-vm.sh" "openclaw config set agents.defaults.model.primary \"$MODEL\""
"$SCRIPT_DIR/openclaw-in-vm.sh" "openclaw config set agents.defaults.model.fallbacks \"[]\" --json"

echo ""
echo "Attempting to restart the gateway in the VM..."
RESTART_OUT=$("$SCRIPT_DIR/openclaw-in-vm.sh" "openclaw gateway restart 2>&1" || true)
echo "$RESTART_OUT"

if echo "$RESTART_OUT" | grep -q "Gateway service not loaded\|service not loaded"; then
  echo ""
  echo "The gateway is not running as a LaunchAgent service."
  echo "To apply the new default model:"
  echo "  1. In the terminal where the gateway is running (e.g. npm run gateway): press Ctrl+C"
  echo "  2. Start it again: npm run gateway"
  echo ""
  echo "To run the gateway as a service so this script can restart it:"
  echo "  npm run run -- 'openclaw gateway install'"
  echo "  Then: npm run gateway:stop && npm run gateway  (or use this script again)"
fi

echo ""
echo "--- Updating the *current* session (e.g. webchat) ---"
echo "The default above applies to new sessions. To use the new model in an existing chat:"
echo "  • In the chat, send a standalone message:  /model $MODEL"
echo "  • Or send:  /model  (then pick from the list)"
echo "  • Or start a new chat/session (it will use the new default)."
echo ""
echo "Done. Default model: $MODEL"
