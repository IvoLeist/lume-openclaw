# Lume + OpenClaw Integration Plan (Summary)

This document summarizes the implementation plan for running Clawdbot (OpenClaw) inside a Lume macOS VM.

## Goal

- Install Lume on the host Mac and create a macOS VM.
- Install and run OpenClaw (Clawdbot) **inside** that VM.
- You use the same environment via: VM desktop (VNC) and OpenClaw channels (Telegram, WhatsApp, webchat, CLI).
- Clawdbot runs in the same VM and has the same capabilities (browser, shell, files).

**Constraint:** Clawdbot must run inside the Lume instance (not on the host).

## Scope of this repo

- **Documentation:** Runbook ([runbook-lume-claw-setup.md](runbook-lume-claw-setup.md)), port-forwarding notes, README.
- **Scripts:** Host-side automation: install Lume, create VM, start/stop VM, run commands in VM via SSH.
- **No forking or vendoring** of Lume or OpenClaw.

## Main deliverables

| Deliverable | Location |
|-------------|----------|
| Step-by-step runbook | [documentation/runbook-lume-claw-setup.md](runbook-lume-claw-setup.md) |
| Lume install script | [scripts/vm/install-lume.sh](../scripts/vm/install-lume.sh) |
| Create VM script | [scripts/vm/create-openclaw-vm.sh](../scripts/vm/create-openclaw-vm.sh) |
| Run command in VM | [scripts/openclaw/openclaw-in-vm.sh](../scripts/openclaw/openclaw-in-vm.sh) |
| Start / stop VM | [scripts/vm/start-vm.sh](../scripts/vm/start-vm.sh), [scripts/vm/stop-vm.sh](../scripts/vm/stop-vm.sh) |
| Port forwarding (webhooks) | [docs/port-forwarding.md](../docs/port-forwarding.md) |
| Repo overview | [README.md](../README.md) |

## Architecture (high level)

- **Host:** Lume CLI (and optional `lume serve`); scripts call `lume` to create/start/stop the VM.
- **VM:** Single macOS VM (e.g. `openclaw`) with OpenClaw Gateway (and daemon) running. User and bot both use this VM.
- **Channels:** Telegram/WhatsApp/webchat connect to the gateway inside the VM; may require port forwarding or a tunnel for webhooks.

## Key references

- [Lume (cua.ai)](https://cua.ai/docs/lume/guide/getting-started/introduction)
- [OpenClaw on macOS VM (Lume)](https://docs.clawd.bot/platforms/macos-vm)
- [OpenClaw Setup](https://docs.clawd.bot/start/setup)
