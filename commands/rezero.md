---
description: Run the Re:ZERO Loop
argument-hint: "<task>"
---

If the user request is `init`, load and follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero-init/SKILL.md` and stop.
If the user request is `bgm <on|off|true|false>`, load and follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero/SKILL.md` for BGM configuration only.

For every other request, first perform the Re:ZERO init gate before any analysis, implementation, subagent spawn, or verification:

1. Check init state:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If any check fails, load and follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero-init/SKILL.md`, commit the init changes, then continue the original request by loading and following `${CLAUDE_PLUGIN_ROOT}/skills/rezero/SKILL.md`.
3. If all checks pass, load and follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero/SKILL.md`.

Do not skip the init gate just because the user did not explicitly request `init`.

User request:
$ARGUMENTS
