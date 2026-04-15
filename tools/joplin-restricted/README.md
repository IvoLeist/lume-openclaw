# joplin-restricted

Small restricted CLI wrapper for the local Joplin Data API.

It only operates on one allowed notebook title:

- `4. OpenClaw`

The tool supports reading notes and creating notes inside that notebook.

## What this tool does

- Resolves the notebook id for `4. OpenClaw`
- Lists notes from that notebook
- Creates new notes in that notebook
- Uses environment variables for API endpoint and token

## Requirements

- Python tooling with `uv`
- A running Joplin instance with the Web Clipper/Data API enabled
- Valid API token for Joplin

## Environment variables

Create a `.env` file in this folder with:

```env
JOPLIN_BASE_URL=http://localhost:41184
JOPLIN_API_TOKEN=<your-token>
```

Notes:
- `JOPLIN_BASE_URL` should point to your local Joplin API endpoint.
- In .env.docker, you may set `JOPLIN_BASE_URL` to http://host.docker.internal:41184

## Local usage

### 1. Install dependencies

```bash
make sync
```

### 2. List notes

```bash
make list-notes
```

### 3. Create a note

```bash
make create-note TITLE="My title" BODY="My note body"
```

### 4. Get the allowed notebook id

```bash
make get-notebook-id
```

## Direct CLI usage

The launcher script calls:

```bash
./joplin-restricted.sh <command> [args]
```

Available commands:

- `get-notebook-id`
- `list-notes`
- `create-note <title> <body>`

Examples:

```bash
./joplin-restricted.sh list-notes
./joplin-restricted.sh create-note "Title" "Body text"
```

## Docker usage

Build image:

```bash
make build-image
```

Run read-only commands in Docker:

```bash
make d-get-notebook-id
make d-list-notes
```

Docker execution uses:

- host network
- read-only filesystem
- tmpfs mounted on `/tmp`

By default it reads environment values from `.env.docker`.

## Security model

- Notebook access is restricted by title to `4. OpenClaw`.
- The CLI does not expose commands for other notebooks.
- You should still treat API credentials as sensitive and avoid logging tokens.

## Troubleshooting

- If commands fail with authentication errors, verify `JOPLIN_API_TOKEN`.
- If connection fails, verify `JOPLIN_BASE_URL` and that Joplin API is running.
- If notebook lookup fails, confirm the notebook title is exactly `4. OpenClaw`.

## Files in this directory

- `joplin_api_wrapper.py`: Typer-based CLI implementation
- `joplin-restricted.sh`: local launcher using `uv run --env-file .env`
- `makefile`: convenience commands for local and Docker execution
- `Dockerfile`: minimal container image for restricted operations
