# Scripts

Host-side scripts for Lume VM and OpenClaw (Clawdbot), grouped by role. Run from the repo root. Set `VM_USER` (and optionally `VM_NAME`, `VM_IP`) for any SSH-based script.

## Layout

```
scripts/
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
| [vm/stop-vm.sh](vm/stop-vm.sh) | Stop the VM. |
| [vm/launch-vm-and-gateway.sh](vm/launch-vm-and-gateway.sh) | Start the VM (if needed), wait for SSH, then run the OpenClaw gateway in this terminal. Use another terminal for TUI. |

## openclaw/ — OpenClaw (inside VM)

| Script | Purpose |
|--------|--------|
| [openclaw/openclaw-gateway.sh](openclaw/openclaw-gateway.sh) | SSH in and run the OpenClaw gateway (for TUI, Telegram, WhatsApp, etc.). Leave running. |
| [openclaw/openclaw-tui.sh](openclaw/openclaw-tui.sh) | SSH in and run the OpenClaw TUI (terminal chat). Start the gateway first in another terminal. |
| [openclaw/openclaw-in-vm.sh](openclaw/openclaw-in-vm.sh) | Run a one-off command in the VM. Example: `VM_USER=geegz ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"`. Requires `VM_USER`. |
| [openclaw/peekaboo-status.sh](openclaw/peekaboo-status.sh) | Run `peekaboo bridge status --verbose` in the VM (verify Peekaboo Bridge). Requires `VM_USER`. |

## connect/ — SSH and access

| Script | Purpose |
|--------|--------|
| [connect/ssh-vm.sh](connect/ssh-vm.sh) | Open an interactive SSH session to the VM. Default `VM_USER`: geegz. |

## Quick reference

- **Start everything (gateway in this terminal):** `./scripts/vm/launch-vm-and-gateway.sh` then in another terminal `./scripts/openclaw/openclaw-tui.sh`.
- **Or step by step:** `./scripts/vm/start-vm.sh` (blocks), then in two other terminals: `./scripts/openclaw/openclaw-gateway.sh` and `./scripts/openclaw/openclaw-tui.sh`.
- **Restart VM:** `./scripts/vm/stop-vm.sh` then `./scripts/vm/start-vm.sh`.
- **SSH into VM:** `./scripts/connect/ssh-vm.sh` or `VM_USER=youruser ./scripts/connect/ssh-vm.sh`.

You can also use **npm scripts** from the repo root (see root [README](../README.md) and `package.json`).
