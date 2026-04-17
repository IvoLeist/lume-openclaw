There seems to be an issue in the OpenClaw codebase

Eventhough when being in a Sandbox the agent keeps on trying to access the files here
- ~/.openclaw/skills/<skill_name>/SKILL.md
- /Users/<username>/.openclaw/skills/<skill_name>/SKILL.md
See Error message below:

[tools] read failed: Sandbox path escapes allowed mounts; 
cannot access: /Users/<username>/.openclaw/skills/joplin-safe/SKILL.md raw_params={"path":"~/.openclaw/skills/joplin-safe/SKILL.md"}

Temporary workaround inserted in Agents.md

### Mandatory path policy for skill files

If you need to read a skill file, use only workspace-visible paths.

Allowed:
- skills/<skill_name>/SKILL.md

Forbidden:
- ~/.openclaw/skills/<skill_name>/SKILL.md
- /Users/<user_name>/.openclaw/skills/<skill_name>/SKILL.md

If a skill location shown elsewhere conflicts with this rule, prefer the workspace path.

! Note with the current `workspaceAccess` setting "ro" changes of any agents files such as AGENTS.md
are only reflected inside the mounted workspaces after a manual deletion of the respective sandbox 
inside "sandboxes" (/Users/<user_name>/.openclaw/sandboxes) in the virtual machine.
