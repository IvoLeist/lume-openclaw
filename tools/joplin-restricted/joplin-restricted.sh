#!/usr/bin/env bash

# This shell wrapper is supposed to be calle via SSH from OpenClaw. 
# The corresponding SSH key is locked down to only allow
# running this script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env.docker"

CMD="${SSH_ORIGINAL_COMMAND:-}"
printf "Received command: %s\n" "$CMD"

case "$CMD" in
  list-notes|get-notebook-id|create-note\ *)
    ;;
  *)
    echo "❌ Command not allowed"
    exit 1
    ;;
esac

DOCKER_BIN="/usr/local/bin/docker"

exec "$DOCKER_BIN" run --rm \
  --env-file "$ENV_FILE" \
  --network host \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  joplin-restricted:latest $CMD