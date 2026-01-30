# Lume + Clawdbot setup — done

Clawdbot runs **inside** the Lume instance. You and the bot use the same VM (same interface and capabilities).

## See the runbook

**Full step-by-step:** [runbook-lume-claw-setup.md](runbook-lume-claw-setup.md)

Covers: Lume install, VM create, Setup Assistant, SSH, OpenClaw install, channels, headless run, golden image, troubleshooting.

## Quick checklist (after first-time setup)

- [ ] Lume installed on host (`./scripts/vm/install-lume.sh`)
- [ ] VM created (`./scripts/vm/create-openclaw-vm.sh`) and Setup Assistant completed
- [ ] Remote Login enabled in VM (System Settings → Sharing)
- [ ] OpenClaw installed inside VM (`VM_USER=user ./scripts/openclaw/openclaw-in-vm.sh "npm install -g openclaw@latest && openclaw onboard --install-daemon"`)
- [ ] Channels configured in `~/.openclaw/openclaw.json` (in VM)
- [ ] VM running headlessly (`./scripts/vm/start-vm.sh`)
- [ ] Optional: port forwarding for webhooks — see [../docs/port-forwarding.md](../docs/port-forwarding.md)

## Links

- [Lume](https://cua.ai/docs/lume/guide/getting-started/introduction)
- [OpenClaw (clawd.bot)](https://clawd.bot/)
