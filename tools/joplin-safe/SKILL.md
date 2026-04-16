---
name: joplin-safe
description: Access a restricted Joplin notebook through the joplin-safe command
bins:
  - /opt/tools/joplin-safe/joplin-safe
---

# Joplin Safe

Use the `joplin-safe` command for Joplin operations.

## Commands

- `joplin-safe list-notes`
- `joplin-safe create-note "Title" "Body"`

## Rules

- Use only `joplin-safe`, never raw ssh, docker, python, uv, or curl.
- Do not expose secrets or API tokens.