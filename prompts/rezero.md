---
description: Run the Re:ZERO Loop
argument-hint: "<task>"
---

If the request is `init`: use `rezero-init` and stop.
If the request is `bgm <on|off|true|false>`: use `rezero` for BGM only.

Otherwise, before any analysis, implementation, subagent spawn, or verification:
1. Verify the init gate:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If any check fails: use `rezero-init`, commit init changes, then continue with `rezero`.
3. Use `rezero`; it must use `rezero-plan` before implementation. Do not skip planning for small requests; `rezero-plan` may return one task.

Request:

$ARGUMENTS
