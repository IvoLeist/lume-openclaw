# Peekaboo Bridge in the Lume VM

This guide walks through running **Peekaboo Bridge** **inside** the Lume macOS VM so the OpenClaw agent can see and automate the VM’s macOS UI (screen snapshots, clicks, etc.). The Control UI (web dashboard) does not provide UI vision; that requires a Peekaboo host app running **inside** the VM with the right macOS permissions.

**Constraints:**

- The Peekaboo host must run **inside the VM** to capture the VM’s screen.
- macOS TCC permissions (Screen Recording, Accessibility) require **manual** approval in the VM’s graphical UI (VNC); they cannot be granted over SSH.
- You can use the existing scripts (`ssh-vm.sh`, `openclaw-in-vm.sh`) to run commands in the VM.

---

## 1. Choose the host app

**Preferred:** **OpenClaw.app** (macOS Companion) — acts as a Peekaboo Bridge host when the bridge is enabled in Settings.

**Fallback:** **Peekaboo.app** — dedicated Peekaboo host; use if OpenClaw.app is unavailable or you prefer a separate app.

Only one host needs to be running with the bridge enabled.

---

## 2. Install the host app in the VM

1. **Download** the macOS Companion (OpenClaw.app) or Peekaboo.app from the OpenClaw site, **inside the VM** (e.g. in the VM’s Safari or via shared folder).
2. **Install** by dragging the app to **Applications** (inside the VM).
3. **Open the app** at least once so macOS can register it and show permission prompts later.

If macOS blocks the app (Gatekeeper): **System Settings → Privacy & Security** → at the bottom, **Open Anyway** for the app.

---

## 3. Enable Peekaboo Bridge

- **OpenClaw.app:** Open the app → **Settings** → enable **Peekaboo Bridge**.
- **Peekaboo.app:** Open the app; the bridge is typically enabled by default (see [Peekaboo docs](https://docs.openclaw.ai/platforms/mac/peekaboo) if your version differs).

When enabled, the host starts a local UNIX socket server that the `peekaboo` CLI uses.

---

## 4. Grant macOS permissions (in the VM UI)

These **must** be done in the VM’s graphical session (VNC), not over SSH, because macOS shows GUI dialogs.

1. Open **System Settings → Privacy & Security**.
2. **Screen Recording** — add **OpenClaw** (or **Peekaboo**). Approve any prompt from the app.
3. **Accessibility** — add **OpenClaw** (or **Peekaboo**). Approve any prompt.

If you don’t see the app in the list, open the host app again and trigger an action that requires the permission; macOS will then show the prompt.

---

## 5. Install the `peekaboo` CLI in the VM

The Peekaboo CLI is installed via **Homebrew** (there is no npm package). Inside the VM (via SSH or VNC Terminal):

```bash
brew install steipete/tap/peekaboo
```

If Homebrew is not installed in the VM, install it first in the VM’s Terminal (requires sudo): [https://brew.sh](https://brew.sh).

From the host, once Homebrew is installed and on PATH in the VM:

```bash
VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "source ~/.zshrc 2>/dev/null || true; brew install steipete/tap/peekaboo"
```

---

## 6. Verify the bridge

Inside the VM:

```bash
peekaboo bridge status --verbose
```

You should see:

- The active host (OpenClaw.app or Peekaboo.app).
- The socket path in use.

From the host you can run:

```bash
VM_USER=youruser ./scripts/openclaw/openclaw-in-vm.sh "peekaboo bridge status --verbose"
```

Optional: use the **[peekaboo-status](../scripts/openclaw/peekaboo-status.sh)** script: `VM_USER=youruser ./scripts/openclaw/peekaboo-status.sh`.

---

## 7. Data flow

- Agent request → gateway tool call → `peekaboo` CLI → Peekaboo Bridge (socket) → host app → screen snapshot of VM UI.

The agent uses the `peekaboo` CLI to request screen snapshots; the host app (running in the VM) captures the VM’s screen and returns the image.

---

## Troubleshooting

| Problem | What to do |
|--------|------------|
| **“Bridge client is not authorized”** | The bridge validates caller code signatures. Use a properly signed client, or in **debug only** run the host with `PEEKABOO_ALLOW_UNSIGNED_SOCKET_CLIENTS=1`. See [Peekaboo docs](https://docs.openclaw.ai/platforms/mac/peekaboo). |
| **No host found** | Open OpenClaw.app or Peekaboo.app in the VM and ensure **Peekaboo Bridge** is enabled in Settings. Then run `peekaboo bridge status --verbose` again. |
| **Permission dialogs never appear over SSH** | macOS shows TCC dialogs only in the graphical session. Use VNC to the VM and grant **Screen Recording** and **Accessibility** in System Settings → Privacy & Security. |
| **Gatekeeper blocks the app** | In the VM: **System Settings → Privacy & Security** → scroll down → **Open Anyway** for the app. |
| **Socket path / discovery** | You can override the socket with `export PEEKABOO_BRIDGE_SOCKET=/path/to/bridge.sock`. Normally discovery is automatic (Peekaboo.app → Claude.app → OpenClaw.app). |

---

## Related

- [Peekaboo (OpenClaw docs)](https://docs.openclaw.ai/platforms/mac/peekaboo)
- [Runbook: Lume + OpenClaw setup](runbook-lume-claw-setup.md) — includes a short Peekaboo section and link to this guide
