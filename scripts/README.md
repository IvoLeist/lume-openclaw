# Scripts

Host-side scripts for a Lume VM running OpenClaw, grouped by role. Run from the repo root.

Before using any SSH-based script, export your VM username:

```bash
export VM_USER=your-vm-username
```

The repo intentionally does not guess a default VM username for public use.

## Layout

```text
scripts/
├── launch-vm-and-gateway.sh  # compatibility wrapper -> vm/launch-vm-and-gateway.sh
├── ssh-vm.sh                 # compatibility wrapper -> connect/ssh-vm.sh
├── vm/          # Lume & VM lifecycle
├── openclaw/    # OpenClaw in VM (gateway, TUI, run command, Peekaboo)
├── connect/     # SSH to VM
└── README.md    # this file
```

## vm/ — VM lifecycle (Lume)

| Script | Purpose |
|--------|--------|
| [vm/install-lume.sh](vm/install-lume.sh) | Install Lume on the host; prints PATH instructions if needed. |
| [vm/create-openclaw-vm.sh](vm/create-openclaw-vm.sh) | Create the macOS VM (e.g. `openclaw`); optional unattended setup. |
| [vm/start-vm.sh](vm/start-vm.sh) | Start the VM headlessly. Use `LUME_DISPLAY=1` to open VNC. |
| [vm/start-vm-with-display.sh](vm/start-vm-with-display.sh) | Start the VM with VNC display (desktop UI). Same as `LUME_DISPLAY=1 ./scripts/vm/start-vm.sh`. |
| [vm/stop-vm.sh](vm/stop-vm.sh) | Stop the VM. |
| [vm/launch-vm-and-gateway.sh](vm/launch-vm-and-gateway.sh) | Start the VM (if needed), wait for SSH, then run the OpenClaw gateway in this terminal. Use another terminal for TUI. |
| [vm/install-postgres-vm.sh](vm/install-postgres-vm.sh) | Install PostgreSQL in the VM via Homebrew and set the postgres role password. Requires `VM_USER`. Set `POSTGRES_PASSWORD` to control the password, or let the script generate one once and reuse it from the VM. The script no longer prints the password unless `PRINT_POSTGRES_PASSWORD=1`. |

## openclaw/ — OpenClaw (inside VM)

| Script | Purpose |
|--------|--------|
| [openclaw/openclaw-gateway.sh](openclaw/openclaw-gateway.sh) | SSH in and run the OpenClaw gateway (for TUI, Telegram, WhatsApp, etc.). Patches LaunchAgent PATH for peekaboo, then starts gateway or tails logs. Leave running. |
| [openclaw/openclaw-stop.sh](openclaw/openclaw-stop.sh) | Stop the OpenClaw gateway/daemon in the VM. Use before relaunching the gateway. |
| [openclaw/openclaw-tui.sh](openclaw/openclaw-tui.sh) | SSH in and run the OpenClaw TUI (terminal chat). Start the gateway first in another terminal. |
| [openclaw/openclaw-in-vm.sh](openclaw/openclaw-in-vm.sh) | Run a one-off command in the VM. Example: `VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"`. Requires `VM_USER`. |
| [openclaw/set-default-model.sh](openclaw/set-default-model.sh) | Set the default OpenClaw model in the VM (default: `vercel-ai-gateway/anthropic/claude-haiku-4.5`), attempt gateway restart, and print how to update the current session (`/model` in chat). Run: `npm run model:set` or `npm run model:set -- <model-id>`. |
| [openclaw/peekaboo-status.sh](openclaw/peekaboo-status.sh) | Run `peekaboo bridge status --verbose` in the VM (verify Peekaboo Bridge). Requires `VM_USER`. |

## connect/ — SSH and access

| Script | Purpose |
|--------|--------|
| [connect/ssh-vm.sh](connect/ssh-vm.sh) | Open an interactive SSH session to the VM. Requires `VM_USER`. |
| [connect/copy-to-vm.sh](connect/copy-to-vm.sh) | Copy a file (e.g. a DMG) from the host to the VM over SSH (scp). Example: `VM_USER=myuser ./scripts/connect/copy-to-vm.sh ./App.dmg ~/Downloads/`. Requires `VM_USER`. |

## Compatibility Wrappers

These top-level scripts are kept so older references keep working:

| Script | Purpose |
|--------|--------|
| [launch-vm-and-gateway.sh](launch-vm-and-gateway.sh) | Wrapper for [vm/launch-vm-and-gateway.sh](vm/launch-vm-and-gateway.sh). |
| [ssh-vm.sh](ssh-vm.sh) | Wrapper for [connect/ssh-vm.sh](connect/ssh-vm.sh). |

## Quick reference

- **First shell setup:** `export VM_USER=your-vm-username`
- **Start everything (gateway in this terminal):** `./scripts/vm/launch-vm-and-gateway.sh` then in another terminal `./scripts/openclaw/openclaw-tui.sh`.
- **Or step by step:** `./scripts/vm/start-vm.sh` (blocks), then in two other terminals: `./scripts/openclaw/openclaw-gateway.sh` and `./scripts/openclaw/openclaw-tui.sh`.
- **Restart VM:** `./scripts/vm/stop-vm.sh` then `./scripts/vm/start-vm.sh`.
- **Stop gateway (to relaunch):** `./scripts/openclaw/openclaw-stop.sh` then `./scripts/openclaw/openclaw-gateway.sh` (or `npm run gateway:stop` then `npm run gateway`).
- **SSH into VM:** `./scripts/connect/ssh-vm.sh` or `VM_USER=youruser ./scripts/connect/ssh-vm.sh`.

You can also use **npm scripts** from the repo root (see root [README](../README.md) and `package.json`).
