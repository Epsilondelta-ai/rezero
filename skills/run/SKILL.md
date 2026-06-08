---
name: run
description: "Run the Re:ZERO Loop. Use for `/rezero:run` in Claude Code or `$rezero:run` in Codex: initialize if needed, plan tasks, let Subaru implement, run Seven Witches review, remember warnings, reset on failures, and commit on pass."
license: MIT
---

# Re:ZERO Run Entry Point

You are the explicit Re:ZERO Loop entry point.

Interpret the user's request as the text following `/rezero:run` in Claude Code or `$rezero:run` in Codex.

## Special requests

- If the request is exactly `init`: load and follow this plugin's `rezero-init` skill, then stop.
- If the request is `bgm <on|off|true|false>`: load and follow this plugin's `rezero` skill for BGM configuration only, then stop.

## Normal requests

Before any analysis, implementation, subagent spawn, or verification:

1. Verify the init gate:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If any check fails:
   - Load and follow this plugin's `rezero-init` skill.
   - Commit init changes.
   - Continue with this plugin's `rezero` skill.
3. Load and follow this plugin's `rezero` skill.
   - It must load/use this plugin's `rezero-plan` skill before implementation.
   - Do not skip planning for small requests; `rezero-plan` may return one task.
