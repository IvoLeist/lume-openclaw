#!/usr/bin/env bash
set -euo pipefail
exec uv run --env-file .env joplin_api_wrapper.py "$@"