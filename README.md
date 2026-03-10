# lume-moltbot

Run [OpenClaw](https://clawd.bot/) (Clawdbot) inside a [Lume](https://cua.ai/docs/lume) macOS VM so both you and the bot use the same environment. Clawdbot runs **inside** the Lume instance (not on the host).

## What this repo is

- **Documentation:** Step-by-step runbook and plan for Lume + OpenClaw setup.
- **Scripts:** Host-side automation to install Lume, create/start/stop the VM, and run commands inside the VM via SSH.
- **Optional:** Port-forwarding notes for channel webhooks (Telegram, WhatsApp).

This repo does **not** fork or vendor Lume or OpenClaw; it documents the flow and provides helper scripts.

## Prerequisites

- **Apple Silicon Mac** (M1/M2/M3/M4). Lume does not run on Intel Macs or other platforms.
- **macOS Sequoia or later** on the host.
- **~60 GB free disk space** per VM.
- **Node.js** (for OpenClaw inside the VM; see [OpenClaw docs](https://docs.clawd.bot/start/setup)).

## Quick start

1. **Install Lume** (on the host):

   ```bash
   ./scripts/vm/install-lume.sh
   ```

2. **Create the macOS VM**:

   ```bash
   ./scripts/vm/create-openclaw-vm.sh
   ```

3. **Follow the runbook** for Setup Assistant (or use unattended), SSH, OpenClaw install, channels, and headless run:

   **[documentation/runbook-lume-claw-setup.md](documentation/runbook-lume-claw-setup.md)**

## NPM scripts (recommended)

From the repo root, with `VM_USER` set if your VM user is not `geegz`:

| Command | Purpose |
|---------|--------|
| `npm run vm:launch` | Start the VM (if needed) and run the OpenClaw gateway in this terminal. Then in another terminal run `npm run tui`. |
| `npm run vm:start` | Start the VM headlessly. |
| `npm run vm:ui` | Start the VM with VNC display (desktop UI). |
| `npm run vm:stop` | Stop the VM. |
| `npm run vm:restart` | Stop then start the VM. |
| `npm run gateway` | SSH in and run the OpenClaw gateway (VM must already be running). |
| `npm run tui` | SSH in and run the OpenClaw TUI (start the gateway first in another terminal). |
| `npm run ssh` | Open an interactive SSH session to the VM. |
| `npm run vm:install` | Install Lume on the host. |
| `npm run vm:create` | Create the macOS VM. |
| `npm run run -- "<cmd>"` | Run a one-off command in the VM (e.g. `npm run run -- "openclaw status"`). Requires `VM_USER`. |
| `npm run peekaboo:status` | Run `peekaboo bridge status --verbose` in the VM. Requires `VM_USER`. |

## Scripts (direct)

Full list and grouping: **[scripts/README.md](scripts/README.md)**.

| Script | Purpose |
|--------|--------|
| [scripts/vm/launch-vm-and-gateway.sh](scripts/vm/launch-vm-and-gateway.sh) | Start VM (if needed) then run gateway in this terminal. |
| [scripts/vm/install-lume.sh](scripts/vm/install-lume.sh) | Install Lume on the host. |
| [scripts/vm/create-openclaw-vm.sh](scripts/vm/create-openclaw-vm.sh) | Create the Lume VM. |
| [scripts/vm/start-vm.sh](scripts/vm/start-vm.sh) | Start the VM headlessly. |
| [scripts/vm/stop-vm.sh](scripts/vm/stop-vm.sh) | Stop the VM. |
| [scripts/connect/ssh-vm.sh](scripts/connect/ssh-vm.sh) | Interactive SSH to the VM. |
| [scripts/openclaw/openclaw-gateway.sh](scripts/openclaw/openclaw-gateway.sh) | Run OpenClaw gateway in VM. |
| [scripts/openclaw/openclaw-tui.sh](scripts/openclaw/openclaw-tui.sh) | Run OpenClaw TUI in VM. |
| [scripts/openclaw/openclaw-in-vm.sh](scripts/openclaw/openclaw-in-vm.sh) | Run a command in the VM (`VM_USER` required). |
| [scripts/openclaw/peekaboo-status.sh](scripts/openclaw/peekaboo-status.sh) | Peekaboo bridge status in VM. |

**Env:** `VM_USER` — SSH username in the VM (default in scripts: `geegz`). Set it if your VM user is different (e.g. `lume` for unattended tahoe).

## Documentation

- **[Runbook: Lume + OpenClaw setup](documentation/runbook-lume-claw-setup.md)** — Full step-by-step from Lume install to Claw in VM, channels, headless run, troubleshooting.
- **[Plan summary](documentation/PLAN-lume-openclaw-integration.md)** — High-level plan and deliverables.
- **[Port forwarding / webhooks](docs/port-forwarding.md)** — Exposing the gateway in the VM for Telegram/WhatsApp webhooks.
- **[Peekaboo Bridge (UI automation)](docs/peekaboo-bridge.md)** — macOS UI automation inside the VM (screen snapshots, clicks).

## Links

- [Lume — cua.ai](https://cua.ai/docs/lume/guide/getting-started/introduction)
- [OpenClaw — clawd.bot](https://clawd.bot/)
- [OpenClaw on macOS VM (Lume)](https://docs.clawd.bot/platforms/macos-vm)
