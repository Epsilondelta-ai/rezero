---
description: Run the Re:ZERO Loop
argument-hint: "<task>"
---

If the user request is `init`: load and follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero-init/SKILL.md` and stop.
If the user request is `bgm <on|off|true|false>`: load and follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero/SKILL.md` for BGM only.

Otherwise, before any analysis, implementation, subagent spawn, or verification:
1. Verify the init gate:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If any check fails: load/follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero-init/SKILL.md`, commit init changes, then continue with `${CLAUDE_PLUGIN_ROOT}/skills/rezero/SKILL.md`.
3. Load/follow `${CLAUDE_PLUGIN_ROOT}/skills/rezero/SKILL.md`; it must load/use `${CLAUDE_PLUGIN_ROOT}/skills/rezero-plan/SKILL.md` before implementation. Do not skip planning for small requests; `rezero-plan` may return one task.

User request:
$ARGUMENTS
