---
description: Run the Re:ZERO Loop
argument-hint: "<task>"
---

If the request is `init`, use the Re:ZERO plugin skill `rezero-init` and stop.
If the request is `bgm <on|off|true|false>`, use the Re:ZERO plugin skill `rezero` for BGM configuration only.

For every other request, first perform the Re:ZERO init gate before any analysis, implementation, subagent spawn, or verification:

1. Check init state:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If any check fails, use the Re:ZERO plugin skill `rezero-init`, commit the init changes, then continue the original request with the Re:ZERO plugin skill `rezero`.
3. If all checks pass, use the Re:ZERO plugin skill `rezero`.

Do not skip the init gate just because the user did not explicitly request `init`.

Request:

$ARGUMENTS
