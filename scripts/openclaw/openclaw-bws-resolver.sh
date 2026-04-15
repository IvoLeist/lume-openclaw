#!/bin/bash

# This script needs to be copied to virtual machine and made executable. 
# It is used by OpenClaw to resolve secrets from Bitwarden Secrets Manager (BWS)

set -euo pipefail

REQUEST="$(cat)"

IDS="$(printf '%s' "$REQUEST" | /usr/bin/jq -r '.ids[]')"

VALUES_JSON="{}"

while IFS= read -r SECRET_ID; do
  [ -n "$SECRET_ID" ] || continue
  SECRET_VALUE="$(/usr/local/bin/bws secret get "$SECRET_ID" | /usr/bin/jq -r '.value')"
  VALUES_JSON="$(printf '%s' "$VALUES_JSON" | /usr/bin/jq --arg id "$SECRET_ID" --arg val "$SECRET_VALUE" '. + {($id): $val}')"
done <<< "$IDS"

printf '%s\n' "$VALUES_JSON" | /usr/bin/jq '{protocolVersion: 1, values: .}'