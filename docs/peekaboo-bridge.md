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

**Peekaboo.app and OpenClaw.app are not installed by default** — you must download and install one of them in the VM.

### Peekaboo.app (standalone host)

- **Download:** [GitHub Releases (steipete/Peekaboo)](https://github.com/steipete/Peekaboo/releases/latest) — open the page **in the VM** (Safari) or on the host, then copy the `.dmg` or `.zip` into the VM.
- **From host to VM:** use the copy script:  
  `VM_USER=myuser ./scripts/connect/copy-to-vm.sh /path/to/Peekaboo-….dmg ~/Downloads/`  
  Then in the VM: open the DMG and drag **Peekaboo.app** to **Applications**.
- **Website (links to releases):** [peekaboo.boo](https://www.peekaboo.boo/) → Download.

### OpenClaw.app (macOS Companion — alternative host)

- **Download:** [OpenClaw macOS Companion](https://docs.clawd.bot/platforms/macos) — follow the doc for the current download (installer or .app/.dmg). Install **inside the VM** (Safari in the VM or copy from host via `copy-to-vm.sh`).

### After download

1. **Install** by dragging the app to **Applications** (inside the VM).
2. **Open the app** at least once so macOS can register it and show permission prompts later.

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

The Peekaboo CLI comes from the [Peekaboo](https://github.com/steipete/Peekaboo) project (steipete), not from an OpenClaw npm package. There is **no** `@openclaw/peekaboo` package; install the CLI via **Homebrew**. Inside the VM (via SSH or VNC Terminal):

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

## 8. Use Peekaboo with OpenClaw

For OpenClaw to use Peekaboo, the gateway must load the **peekaboo skill** and be able to run the `peekaboo` binary. Do the following **inside the VM**.

### 8.1 Enable the peekaboo skill in config

OpenClaw uses a **skills** system; the peekaboo skill is often bundled and gated by the presence of the `peekaboo` binary on PATH. Enable it in your config.

Config file:

- **`~/.openclaw/openclaw.json`**

Add or merge a `skills.entries` section with `peekaboo` enabled:

```json
{
  "skills": {
    "entries": {
      "peekaboo": { "enabled": true }
    }
  }
}
```

If you use **`allowBundled`** (only certain bundled skills are loaded), include `"peekaboo"` in that list:

```json
{
  "skills": {
    "allowBundled": ["peekaboo", "…"],
    "entries": {
      "peekaboo": { "enabled": true }
    }
  }
}
```

Save the file. See [Skills config](https://docs.clawd.bot/tools/skills-config) for the full schema.

### 8.2 Ensure the gateway can find `peekaboo`

The peekaboo skill is **gated by the `peekaboo` binary**: the gateway checks at load time that `peekaboo` is on **PATH**. If you installed the CLI to **`~/bin/peekaboo`**, the **gateway process** must run with PATH that includes `$HOME/bin`.

- **If you start the gateway from a Terminal (SSH or VNC):** run `source ~/.zshrc` (or open a login shell) so that `~/bin` is on PATH, then start the gateway (e.g. `openclaw gateway` or `openclaw tui`). The agent will then see the peekaboo skill and can call the CLI.
- **If the gateway runs as a daemon/service:** run the gateway script from the host: `npm run gateway` (or `./scripts/openclaw/openclaw-gateway.sh`). It patches the LaunchAgent PATH in the VM (so `peekaboo` and `openclaw` are on PATH) before starting or tailing the gateway. Start a **new** chat/session after that so the agent can use the peekaboo skill.

Optional: add `export PATH="$HOME/bin:$PATH"` to `~/.zshrc` (or equivalent) in the VM if not already there, so any shell-started gateway has it.

### 8.3 Restart the gateway and start a new session

Skills are snapshotted when a session starts. After changing config or PATH:

1. Restart the gateway (and daemon if you use it).
2. Open a **new** chat/session (TUI, Telegram, WhatsApp, etc.).

The agent can then use the peekaboo skill to take screenshots, click, type, etc. on the VM’s macOS UI (as long as the Peekaboo Bridge host app is running and permissions are granted).

### Quick checklist

| Step | Done |
|------|------|
| Peekaboo CLI installed in VM (e.g. `~/bin/peekaboo` or `brew`) | ☐ |
| `peekaboo` on PATH when the gateway runs | ☐ |
| OpenClaw.app or Peekaboo.app running in VM with **Peekaboo Bridge** enabled | ☐ |
| Screen Recording + Accessibility granted for the host app | ☐ |
| `skills.entries.peekaboo.enabled: true` in config | ☐ |
| Gateway restarted, new session started | ☐ |

---

## Troubleshooting

| Problem | What to do |
|--------|------------|
| **“Bridge client is not authorized”** | The bridge validates caller code signatures. Use a properly signed client, or in **debug only** run the host with `PEEKABOO_ALLOW_UNSIGNED_SOCKET_CLIENTS=1`. See [Peekaboo docs](https://docs.openclaw.ai/platforms/mac/peekaboo). |
| **No host found** | Open OpenClaw.app or Peekaboo.app in the VM and ensure **Peekaboo Bridge** is enabled in Settings. Then run `peekaboo bridge status --verbose` again. |
| **Permission dialogs never appear over SSH** | macOS shows TCC dialogs only in the graphical session. Use VNC to the VM and grant **Screen Recording** and **Accessibility** in System Settings → Privacy & Security. |
| **Gatekeeper blocks the app** | In the VM: **System Settings → Privacy & Security** → scroll down → **Open Anyway** for the app. |
| **Socket path / discovery** | You can override the socket with `export PEEKABOO_BRIDGE_SOCKET=/path/to/bridge.sock`. Normally discovery is automatic (Peekaboo.app → Claude.app → OpenClaw.app). |
| **Peekaboo skill not used / “peekaboo not found”** | The gateway daemon’s PATH may not include `~/bin`. Run `npm run gateway` (or `./scripts/openclaw/openclaw-gateway.sh`) so it patches the LaunchAgent PATH, then start a new chat/session. |

---

## Related

- [Peekaboo (OpenClaw docs)](https://docs.openclaw.ai/platforms/mac/peekaboo)
- [Runbook: Lume + OpenClaw setup](runbook-lume-openclaw-setup.md) — includes a short Peekaboo section and link to this guide
