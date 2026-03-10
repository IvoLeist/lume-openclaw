# Runbook: Lume + OpenClaw Setup

This runbook walks through installing Lume on your host Mac, creating a macOS VM, and running OpenClaw **inside** that VM. You and the bot both use the same Lume instance: you via the VM desktop (VNC) and OpenClaw’s channels (Telegram, WhatsApp, webchat, CLI); the bot runs in the same VM and has the same capabilities (browser, shell, files).

**Constraint:** OpenClaw must run inside the Lume instance (not on the host).

**Prerequisites:** Apple Silicon Mac (M1/M2/M3/M4), macOS Sequoia or later on the host, ~60 GB free disk space per VM, ~20 minutes.

---

## 1. Install Lume on the host

Use the official install script:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/trycua/cua/main/libs/lume/scripts/install.sh)"
```

If `~/.local/bin` is not in your PATH (common on fresh macOS), add it:

```bash
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc && source ~/.zshrc
```

Or use the project script:

```bash
./scripts/vm/install-lume.sh
```

Verify:

```bash
lume --version
```

---

## 2. Create the macOS VM

Create a VM named `openclaw` (or use the project script):

```bash
lume create openclaw --os macos --ipsw latest
```

This downloads the macOS IPSW (~15 GB) and creates the VM. A VNC window opens automatically when the VM starts.

**Optional — unattended setup:** To skip manual Setup Assistant and get a pre-configured user (e.g. `lume` / `lume` with SSH enabled), use:

```bash
lume create openclaw --os macos --ipsw latest --unattended tahoe
```

Takes 10–15 minutes; no interaction. Change the default password after first login.

**Alternative:** Use the script:

```bash
./scripts/vm/create-openclaw-vm.sh
```

To start the VM with the desktop UI again later, use one of these on the host:

```bash
./scripts/vm/start-vm-with-display.sh
```

```bash
LUME_DISPLAY=1 ./scripts/vm/start-vm.sh
```

If the VM is already running headlessly, stop it first:

```bash
./scripts/vm/stop-vm.sh
```

---

## 3. Complete Setup Assistant (if not using unattended)

In the VNC window:

1. Select language and region.
2. Skip Apple ID (or sign in if you want iMessage later).
3. Create a user account (remember the username and password).
4. Skip optional features.

After setup, enable SSH:

1. Open **System Settings → General → Sharing**.
2. Enable **Remote Login**.

---

## 4. Get the VM’s IP address

From the host:

```bash
lume get openclaw
```

Note the IP (usually `192.168.64.x`). If the VM is still booting, wait and run again.

---

## 5. SSH into the VM

```bash
ssh youruser@<VM_IP>
```

Replace `youruser` with the account you created (or `lume` if you used unattended). For scripting, set `VM_USER` and use:

```bash
export VM_USER=youruser
./scripts/openclaw/openclaw-in-vm.sh "openclaw status"
```

The helper scripts require `VM_USER` to be set explicitly so they do not guess the wrong username for your VM.

---

## 6. Install OpenClaw inside the VM

Use the current npm CLI package: **`openclaw@latest`**. The Peekaboo CLI is a separate project (see [Peekaboo Bridge](peekaboo-bridge.md)); it is not published as `@openclaw/peekaboo` and should be installed via Homebrew: `brew install steipete/tap/peekaboo`.

**Inside the VM** (via SSH or VNC):

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

Follow the onboarding prompts to set up your model provider (Anthropic, OpenAI, etc.).

Or from the host (replace `youruser` with your VM user):

```bash
VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "npm install -g openclaw@latest && openclaw onboard --install-daemon"
```

Note: Interactive onboarding is easier when you SSH in manually; use the script for non-interactive installs or status checks.

---

## 7. Configure channels

Inside the VM, edit the config:

```bash
nano ~/.openclaw/openclaw.json
```

Example (adjust for your channels):

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+15551234567"]
    },
    "telegram": {
      "botToken": "YOUR_BOT_TOKEN"
    }
  }
}
```

Then log in to WhatsApp (scan QR):

```bash
openclaw channels login
```

For Telegram and other channels, see [OpenClaw channels docs](https://docs.clawd.bot/channels).

**Webhooks:** If you use Telegram/WhatsApp webhooks, the gateway inside the VM must be reachable from the internet. See [Port forwarding / webhooks](port-forwarding.md).

---

## 8. Run the VM headlessly

From the host, stop the VM (if it was running with a display) and start it without a VNC window:

```bash
lume stop openclaw
lume run openclaw --no-display
```

Or use the scripts:

```bash
./scripts/vm/stop-vm.sh
./scripts/vm/start-vm.sh
```

The VM runs in the background. OpenClaw’s daemon keeps the gateway running inside the VM.

To switch back to the desktop UI later, stop the headless VM and start it with display:

```bash
./scripts/vm/stop-vm.sh
./scripts/vm/start-vm-with-display.sh
```

Check status from the host:

```bash
VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "openclaw status"
```

Or SSH in and run `openclaw status` or `openclaw health`.

---

## 9. Golden image (optional)

Before heavy customization, clone the VM so you can reset later:

```bash
lume stop openclaw
lume clone openclaw openclaw-golden
```

To reset to the golden state:

```bash
lume stop openclaw
lume delete openclaw
lume clone openclaw-golden openclaw
lume run openclaw --no-display
```

---

## 10. Running 24/7

To keep the VM running continuously:

- Keep your Mac plugged in.
- Disable sleep in **System Settings → Energy Saver** (or use **Battery**).
- Use `caffeinate` on the host if needed.

For true always-on, consider a dedicated Mac mini or a small VPS; see [OpenClaw VPS hosting](https://docs.clawd.bot/vps).

---

## 11. Bonus: iMessage (macOS VM only)

Inside the VM you can use [BlueBubbles](https://bluebubbles.app) to add iMessage to OpenClaw:

1. Download BlueBubbles in the VM.
2. Sign in with your Apple ID.
3. Enable the Web API and set a password.
4. Point BlueBubbles webhooks at your gateway (e.g. `https://your-gateway-host:3000/bluebubbles-webhook?password=<password>`).

Add to `~/.openclaw/openclaw.json`:

```json
{
  "channels": {
    "bluebubbles": {
      "serverUrl": "http://localhost:1234",
      "password": "your-api-password",
      "webhookPath": "/bluebubbles-webhook"
    }
  }
}
```

See [BlueBubbles channel](https://docs.clawd.bot/channels/bluebubbles) for full setup.

---

## 12. Troubleshooting

| Problem | Solution |
|--------|----------|
| `lume` command not found | Add `~/.local/bin` to PATH (see step 1). |
| Can’t SSH into VM | Ensure **Remote Login** is enabled in the VM’s System Settings → Sharing. |
| VM IP not showing | Wait for the VM to fully boot, then run `lume get openclaw` again. |
| WhatsApp QR not scanning | Run `openclaw channels login` while logged into the VM (VNC or SSH), not from the host. |
| Gateway not reachable for webhooks | Use port forwarding or a tunnel; see [port-forwarding.md](port-forwarding.md). |

---

## 13. Updating OpenClaw inside the VM

SSH into the VM and run:

```bash
npm install -g openclaw@latest
openclaw update
```

Or from the host:

```bash
VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "npm install -g openclaw@latest && openclaw update"
```

Restart the gateway/daemon if required by the release notes.

---

## 14. Peekaboo Bridge (macOS UI automation) in the VM

To let the OpenClaw agent **see and automate the macOS UI** inside the VM (e.g. take screen snapshots, drive clicks), you need **Peekaboo Bridge** running **inside** the VM. The Control UI (web dashboard) does not provide UI vision; that requires a Peekaboo host app in the VM with the right macOS permissions.

**Host app:** Use **OpenClaw.app** (macOS Companion) inside the VM as the Peekaboo host. Alternatively you can use [Peekaboo.app](https://docs.openclaw.ai/platforms/mac/peekaboo) if you prefer.

**Steps (must be done in the VM, some via VNC):**

1. **Install OpenClaw.app in the VM** — Download the macOS Companion from the OpenClaw site and drag it to Applications (inside the VM). Open it at least once.
2. **Enable Peekaboo Bridge** — In the app: **Settings → Enable Peekaboo Bridge**.
3. **Grant macOS permissions** — In the VM’s **System Settings → Privacy & Security**:
   - **Screen Recording**: add OpenClaw (or Peekaboo).
   - **Accessibility**: add OpenClaw (or Peekaboo).
   These prompts appear in the VM’s GUI; they cannot be granted over SSH.
4. **Install the `peekaboo` CLI inside the VM** — Install via Homebrew: `brew install steipete/tap/peekaboo`. If Homebrew is not installed in the VM, install it first (in the VM’s Terminal, with sudo): [Homebrew install](https://brew.sh). Then from the host you can run:
   ```bash
   VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "brew install steipete/tap/peekaboo"
   ```
   (Requires Homebrew and a login shell so `brew` is on PATH; otherwise run the brew command inside the VM.)
5. **Verify** — Inside the VM (or via the script):
   ```bash
   peekaboo bridge status --verbose
   ```
   You should see the host (OpenClaw.app or Peekaboo.app) and the socket path.

For a full step-by-step guide, troubleshooting (e.g. “bridge client not authorized”, Gatekeeper blocking the app), and the Peekaboo.app fallback, see **[Peekaboo Bridge in the VM](peekaboo-bridge.md)** (including how to enable the skill and PATH for the gateway).

---

## Related docs

- [Lume Installation](https://cua.ai/docs/lume/guide/getting-started/installation)
- [Lume Quickstart](https://cua.ai/docs/lume/guide/getting-started/quickstart)
- [OpenClaw on macOS VM (Lume)](https://docs.clawd.bot/platforms/macos-vm)
- [OpenClaw Setup](https://docs.clawd.bot/start/setup)
- [Port forwarding / webhooks](port-forwarding.md) (this repo)
- [Peekaboo Bridge in the VM](peekaboo-bridge.md) — macOS UI automation inside the VM
