# OpenClaw / Clawdbot config — paste this for remote audit

Config extracted from VM via `./scripts/openclaw/openclaw-in-vm.sh`.  
**Secrets redacted** (API keys, tokens, gateway auth). Replace placeholders if you need to share real values in a secure channel.

---

## 1. Main config: `~/.openclaw/openclaw.json` (redacted)

```json
{
  "meta": {
    "lastTouchedVersion": "2026.1.29",
    "lastTouchedAt": "2026-02-01T14:42:57.657Z"
  },
  "env": {
    "OPENAI_API_KEY": "<REDACTED>"
  },
  "wizard": {
    "lastRunAt": "2026-01-30T20:10:33.028Z",
    "lastRunVersion": "2026.1.29",
    "lastRunCommand": "onboard",
    "lastRunMode": "local"
  },
  "auth": {
    "profiles": {
      "vercel-ai-gateway:default": {
        "provider": "vercel-ai-gateway",
        "mode": "api_key"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "vercel-ai-gateway/anthropic/claude-haiku-4.5",
        "fallbacks": []
      },
      "models": {
        "vercel-ai-gateway/anthropic/claude-opus-4.5": { "alias": "Vercel AI Gateway" },
        "vercel-ai-gateway/anthropic/claude-sonnet-4.5": { "alias": "Claude Sonnet 4.5" },
        "vercel-ai-gateway/anthropic/claude-haiku-4.5": { "alias": "Claude Haiku 4.5" }
      },
      "workspace": "/Users/geegz/.openclaw/workspace",
      "compaction": { "mode": "safeguard" },
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 }
    }
  },
  "tools": {
    "web": {
      "search": {
        "provider": "brave",
        "apiKey": "<REDACTED>",
        "maxResults": 5,
        "timeoutSeconds": 30
      }
    }
  },
  "messages": { "ackReactionScope": "group-mentions" },
  "commands": { "native": "auto", "nativeSkills": "auto" },
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "boot-md": { "enabled": true },
        "command-logger": { "enabled": true },
        "session-memory": { "enabled": true }
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "<REDACTED>",
      "groupPolicy": "allowlist",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": { "mode": "token", "token": "<REDACTED>" },
    "tailscale": { "mode": "off", "resetOnExit": false }
  },
  "skills": {
    "install": { "nodeManager": "npm" },
    "entries": { "peekaboo": { "enabled": true } }
  },
  "plugins": {
    "entries": { "telegram": { "enabled": true } }
  }
}
```

---

## 2. Agent defaults (`openclaw config get agents.defaults`)

```json
{
  "model": {
    "primary": "vercel-ai-gateway/anthropic/claude-haiku-4.5",
    "fallbacks": []
  },
  "models": {
    "vercel-ai-gateway/anthropic/claude-opus-4.5": { "alias": "Vercel AI Gateway" },
    "vercel-ai-gateway/anthropic/claude-sonnet-4.5": { "alias": "Claude Sonnet 4.5" },
    "vercel-ai-gateway/anthropic/claude-haiku-4.5": { "alias": "Claude Haiku 4.5" }
  },
  "workspace": "/Users/geegz/.openclaw/workspace",
  "compaction": { "mode": "safeguard" },
  "maxConcurrent": 4,
  "subagents": { "maxConcurrent": 8 }
}
```

---

## 3. Sample agent config (structure)

- **Agent ID:** `main`
- **Location:** `~/.openclaw/agents/main/`
- **Per-agent files:**  
  - `agent/auth-profiles.json` — auth profile references (per-agent API keys; redact before sharing).  
  - `sessions/sessions.json` — session list (not needed for config audit).

There is no separate `agent.json` for `main`; it uses global `agents.defaults` from `openclaw.json`.

**Agent auth-profiles.json (redacted):**
```json
{
  "version": 1,
  "profiles": {
    "vercel-ai-gateway:default": {
      "type": "api_key",
      "provider": "vercel-ai-gateway",
      "key": "<REDACTED>"
    }
  },
  "lastGood": { "vercel-ai-gateway": "vercel-ai-gateway:default" }
}
```

---

## 4. Skills list (`openclaw skills list`)

**Summary:** 26/65 skills ready. Only `peekaboo` is explicitly enabled in `skills.entries` in `openclaw.json`; the rest are available by default (bundled or workspace) and become ready when their CLI/dependency is installed.****

| Status   | Skill              | Source             |
|----------|--------------------|--------------------|
| ✓ ready  | apple-reminders    | openclaw-workspace |
| ✓ ready  | bird               | openclaw-bundled   |
| ✓ ready  | bluebubbles        | openclaw-bundled   |
| ✓ ready  | clawdhub           | openclaw-bundled   |
| ✓ ready  | openai-image-gen   | openclaw-bundled   |
| ✓ ready  | openai-whisper-api | openclaw-bundled   |
| ✓ ready  | **peekaboo**       | openclaw-bundled   |
| ✓ ready  | video-frames       | openclaw-bundled   |
| ✓ ready  | weather            | openclaw-bundled   |
| ✓ ready  | cron-gen           | openclaw-workspace |
| ✓ ready  | sql-gen            | openclaw-workspace |
| ✓ ready  | bankr              | openclaw-workspace |
| ✓ ready  | base               | openclaw-workspace |
| ✓ ready  | clanker            | openclaw-workspace |
| ✓ ready  | ens-primary-name   | openclaw-workspace |
| ✓ ready  | neynar             | openclaw-workspace |
| ✓ ready  | onchainkit         | openclaw-workspace |
| ✓ ready  | qrcoin             | openclaw-workspace |
| ✓ ready  | yoink              | openclaw-workspace |
| ✓ ready  | zapper             | openclaw-workspace |
| ✓ ready  | calendar           | openclaw-workspace |
| ✓ ready  | evm-wallet-skill   | openclaw-workspace |
| ✓ ready  | markdown-converter | openclaw-workspace |
| ✓ ready  | postgres           | openclaw-workspace |
| ✓ ready  | remind-me          | openclaw-workspace |

**Disabled / missing (39):** 1password, apple-notes, bear-notes, blogwatcher, blucli, camsnap, coding-agent, eightctl, gemini, gifgrep, github, gog, goplaces, himalaya, imsg, local-places, mcporter, model-usage, nano-banana-pro, nano-pdf, notion, obsidian, openai-whisper, openhue, oracle, ordercli, sag, session-logs, sherpa-onnx-tts, songsee, sonoscli, spotify-player, summarize, things-mac, tmux, trello, voice-call, wacli, (and any others not listed above).

**Config override in `openclaw.json`:**
```json
"skills": {
  "install": { "nodeManager": "npm" },
  "entries": { "peekaboo": { "enabled": true } }
}
```
*(Only skills explicitly set in `skills.entries` are toggled; others follow default availability.)*

Tip: use `npx clawdhub` to search, install, and sync skills.

---

## 5. Minimum viable agent setup — checklist

Use this when auditing or building a minimal OpenClaw/Clawdbot agent setup:

| Item | Description |
|------|-------------|
| **Auth** | At least one `auth.profiles` entry (e.g. `vercel-ai-gateway:default`) or env (e.g. `OPENAI_API_KEY`) so the agent can call the model. |
| **Model** | `agents.defaults.model.primary` set to a valid model ID (e.g. `vercel-ai-gateway/anthropic/claude-haiku-4.5`). |
| **Workspace** | `agents.defaults.workspace` pointing to an existing directory (e.g. `~/.openclaw/workspace`). |
| **Gateway** | If using TUI/Telegram/etc.: `gateway.port`, `gateway.mode`, and optionally `gateway.auth` (token or none). |
| **Channels** | If using Telegram: `channels.telegram.enabled: true`, valid `botToken`, and policies (`dmPolicy`, `groupPolicy`). |
| **Skills** | Optional: e.g. `skills.entries.peekaboo.enabled: true` if using Peekaboo; ensure binary on PATH where the gateway runs. |
| **Commands** | `commands.native` and `commands.nativeSkills` (e.g. `"auto"`) if you want native/skill execution. |

**Minimal `openclaw.json` for a single agent:**  
`meta`, `auth` (or env), `agents.defaults` (model + workspace), and `gateway` (if not CLI-only). Add `channels`, `tools`, `skills` as needed.
