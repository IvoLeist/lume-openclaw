---
name: joplin-safe
description: Access a restricted Joplin notebook through the joplin-safe command on the gateway host.
bins:
  - joplin-safe
---

# Joplin Safe

Use the `joplin-safe` command for Joplin operations.

## Commands

- `joplin-safe list-notes`
- `joplin-safe create-note "Title" "Body"`

## Rules

- Use only `joplin-safe`, never raw ssh, docker, python, uv, or curl.
- This command must run on the gateway host, not in the sandbox.
- Do not expose secrets or API tokens.