# lume-openclaw

Host-side scripts and docs for running [OpenClaw](https://clawd.bot/) inside a [Lume](https://cua.ai/docs/lume/guide/getting-started/introduction) macOS VM. The bot runs inside the VM, not on the host, so you and the bot share the same macOS environment.

## What This Repo Contains

- `docs/`: setup runbook plus focused guides for webhooks and Peekaboo.
- `docs/README.md`: index of the publishable docs in this repo.
- `scripts/`: bash helpers for installing Lume, creating and controlling the VM, SSHing into it, and running OpenClaw inside it.
- `package.json`: optional `npm run` aliases for the shell scripts.

This repo does not vendor Lume or OpenClaw. It documents the workflow and automates the host-side pieces around them.

## Requirements

- Apple Silicon Mac (`M1`/`M2`/`M3`/`M4`)
- macOS Sequoia or later on the host
- Roughly 60 GB free disk space per VM
- Internet access to download the macOS image and OpenClaw
- Node.js inside the VM to install OpenClaw (see [OpenClaw setup](https://docs.clawd.bot/start/setup))
- Optional on the host: Node.js and npm, only if you want to use the `npm run ...` shortcuts

You do not need to run `npm install` in this repo to use the bash scripts.

## Quickstart

1. Install Lume on the host:

   ```bash
   ./scripts/vm/install-lume.sh
   ```

   If `lume` is still not on your `PATH`, follow the script output and add `$HOME/.local/bin`.

2. Create the VM:

   ```bash
   ./scripts/vm/create-openclaw-vm.sh
   ```

   Optional unattended setup:

   ```bash
   UNATTENDED=tahoe ./scripts/vm/create-openclaw-vm.sh
   ```

   Manual mode opens a VNC window. Finish macOS Setup Assistant, create a user, then enable `Remote Login` in `System Settings -> General -> Sharing`.

3. Export the VM username for the helper scripts.

   The SSH-based scripts require `VM_USER` so they do not guess the wrong username for your VM:

   ```bash
   export VM_USER=your-vm-username
   ```

   If you used unattended setup, that is:

   ```bash
   export VM_USER=lume
   ```

4. SSH into the VM and install OpenClaw:

   ```bash
   ./scripts/connect/ssh-vm.sh
   ```

   If `npm` is not available yet inside the VM, install Node.js there first by following the official OpenClaw setup docs.

   Inside the VM:

   ```bash
   npm install -g openclaw@latest
   openclaw onboard --install-daemon
   ```

   The onboarding flow configures your model provider and gateway daemon.

5. Start the gateway from the host:

   ```bash
   ./scripts/vm/launch-vm-and-gateway.sh
   ```

6. In a second terminal, open the TUI:

   ```bash
   ./scripts/openclaw/openclaw-tui.sh
   ```

7. Verify the daemon from the host when needed:

   ```bash
   ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"
   ```

Use the full runbook for channel setup, webhooks, headless operation, BlueBubbles, Peekaboo, and troubleshooting:
[docs/runbook-lume-openclaw-setup.md](docs/runbook-lume-openclaw-setup.md)

## Optional npm Aliases

If you have Node.js/npm on the host, you can use the shortcuts in `package.json`. These aliases call the same shell scripts; no repo install step is required.

For any SSH-based alias, export `VM_USER` first:

```bash
export VM_USER=your-vm-username
```

| Command | Purpose |
|---------|--------|
| `npm run vm:install` | Install Lume on the host. |
| `npm run vm:create` | Create the VM (`VM_NAME`, default `openclaw`). |
| `npm run vm:start` | Start the VM headlessly. |
| `npm run vm:ui` | Start the VM with a VNC display. |
| `npm run vm:stop` | Stop the VM. |
| `npm run vm:restart` | Stop then start the VM. |
| `npm run vm:launch` | Start the VM if needed, wait for SSH, then run the gateway in this terminal. |
| `npm run gateway` | SSH into the VM and run the OpenClaw gateway, or tail logs if the daemon is already running. |
| `npm run gateway:stop` | Stop the OpenClaw gateway/daemon in the VM. |
| `npm run tui` | SSH into the VM and run the OpenClaw TUI. Start the gateway first. |
| `npm run ssh` | Open an interactive SSH session to the VM. |
| `npm run run -- "<cmd>"` | Run a one-off command in the VM. Example: `npm run run -- "openclaw status"`. |
| `npm run model:set -- <model-id>` | Change the default OpenClaw model inside the VM. |
| `npm run peekaboo:status` | Run `peekaboo bridge status --verbose` in the VM. |

## Environment Variables

| Variable | Default | Purpose |
|---------|---------|---------|
| `VM_NAME` | `openclaw` | Name of the Lume VM to control. |
| `VM_USER` | required for SSH-based scripts | SSH username inside the VM. |
| `VM_IP` | auto-detected | Override VM IP resolution if needed. |
| `UNATTENDED` | unset | Set to `tahoe` when creating an unattended VM. |
| `IPSW` | `latest` | macOS image passed to `lume create`. |
| `LUME_DISPLAY` | unset | Set to `1` when using `scripts/vm/start-vm.sh` to open the VNC display. |

## Scripts

Full script inventory and examples:
[scripts/README.md](scripts/README.md)

Useful direct entry points:

| Script | Purpose |
|--------|--------|
| [scripts/vm/install-lume.sh](scripts/vm/install-lume.sh) | Install Lume on the host. |
| [scripts/vm/create-openclaw-vm.sh](scripts/vm/create-openclaw-vm.sh) | Create the VM. |
| [scripts/vm/launch-vm-and-gateway.sh](scripts/vm/launch-vm-and-gateway.sh) | Start the VM if needed and run the gateway. |
| [scripts/connect/ssh-vm.sh](scripts/connect/ssh-vm.sh) | Open an SSH session to the VM. |
| [scripts/openclaw/openclaw-gateway.sh](scripts/openclaw/openclaw-gateway.sh) | Run the OpenClaw gateway in the VM. |
| [scripts/openclaw/openclaw-tui.sh](scripts/openclaw/openclaw-tui.sh) | Run the OpenClaw TUI in the VM. |
| [scripts/openclaw/openclaw-in-vm.sh](scripts/openclaw/openclaw-in-vm.sh) | Run a one-off command inside the VM. |
| [scripts/openclaw/set-default-model.sh](scripts/openclaw/set-default-model.sh) | Update the default OpenClaw model in the VM. |

## Documentation

- [docs/README.md](docs/README.md): docs index and reading order
- [docs/runbook-lume-openclaw-setup.md](docs/runbook-lume-openclaw-setup.md): full step-by-step setup and operations guide
- [docs/port-forwarding.md](docs/port-forwarding.md): exposing the gateway for webhooks
- [docs/peekaboo-bridge.md](docs/peekaboo-bridge.md): UI automation inside the VM with Peekaboo

## Links

- [Lume installation](https://cua.ai/docs/lume/guide/getting-started/installation)
- [Lume quickstart](https://cua.ai/docs/lume/guide/getting-started/quickstart)
- [OpenClaw setup](https://docs.clawd.bot/start/setup)
- [OpenClaw macOS VM guide](https://docs.clawd.bot/platforms/macos-vm)
