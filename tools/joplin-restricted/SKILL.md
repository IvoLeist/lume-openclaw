---
name: joplin-restricted
description: Safely access only the allowed Joplin notebook through the local joplin-restricted CLI.
metadata:
  openclaw: true
bins:
  - joplin-restricted   
---

# joplin-restricted

Use `joplin-restricted` to interact with the user's restricted Joplin notebook only.

## Commands

### List notes
```bash
joplin-restricted list-notes
```

### Create a new note
```bash
joplin-restricted create-note "Title" "Body text"
```

## Rules
-	Only use this skill for Joplin note operations.
- Do not attempt to access any other notebook.
- Do not print or expose JOPLIN_API_TOKEN.
- Prefer this skill over raw curl or direct API calls.