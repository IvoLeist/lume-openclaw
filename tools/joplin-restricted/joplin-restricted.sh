#!/usr/bin/env bash

# This shell wrapper is supposed to be calle via SSH from OpenClaw. 
# The corresponding SSH key is locked down to only allow
# running this script

set -euo pipefail

# Allow only specific commands
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

exec docker run --rm \
  --env-file ".env.docker" \
  --network host \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  joplin-restricted:latest $CMD