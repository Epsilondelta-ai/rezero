---
name: rezero
description: "Orchestrate the Re:ZERO Loop. Use for /rezero requests: split large work, let Subaru implement, call Seven Witches, send warnings to Rem, reset on fail, and commit on pass."
license: MIT
---

# Re:ZERO

Goal → finish request through small Re:ZERO attempts.

## Flow

0. If request is `init`, use `rezero-init` and stop.
0. If request is `bgm <value>`, configure Return by Death BGM and stop:
   - Off values: `false`, `off`, `0`, `no`, `disable`, `disabled`.
   - On values: `true`, `on`, `1`, `yes`, `enable`, `enabled`.
   - Create or update `.rezero/memory/config.json` in the current project with `{ "bgm": false }` or `{ "bgm": true }` so the setting survives Return by Death resets.
   - Preserve other existing JSON keys when possible.
   - Do not run init, witches, reset, or commit for this configuration-only command.
1. Before any non-init request, check init state:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If init state is missing, run `rezero-init`, commit init changes, then continue the original request.
3. If request is large, use `rezero-plan`; otherwise one task.
4. If planned tasks are independent, run safe groups in parallel via subagents; use team agents for long/heavy groups.
5. Isolate parallel implementation work, merge the group, then verify the combined result.
6. Use `rezero-witches` once for the whole merged group; witches must use fresh context, not Subaru's context.
7. Aggregate every witch result and show the witch verdict table in the assistant chat as a hard barrier.
8. Do not reset, retry, call Rem, commit, continue another loop, or give a final summary until the verdict table has been shown in chat.
9. Any `fail` → after the chat verdict table, record minimal death memory → announce in chat which Death/Return by Death number is happening → `git reset --hard HEAD` → `git clean -fd` → retry with changed route.
10. Only `pass|warning` → after the chat verdict table, use `rezero-rem` for warnings; if `.rezero/memory/rem.md` is written, show the newly written Rem entries in chat → commit accepted route → delete death memory.
11. If processing Rem warnings, use `rezero-rem` resolution rules.

## Language

Use the user's language for chat output.
Always use English names for spawned subagents, team agents, display names, session names, and verdict tables, regardless of the user's language.

Parallel implementer names are names only; no character behavior.
Use these English names for parallel implementers: Beatrice, Emilia, Ram, Garfiel, Julius.
Use these English names for witch reviewers: Echidna, Typhon, Minerva, Daphne, Carmilla, Sekhmet, Satella.

## Death Memory

Before reset, append to `.rezero/memory/subaru-deaths.md`:

```markdown
## Death <number>

- Fail: <witch + reason>
- Evidence: <minimal test/review/error/defect>
- Next route: <specific change>
```

## Rules

- Sequential task = implement → verify → witches → chat verdict table → commit or reset.
- Parallel group = parallel implement → merge → verify combined result → one witches evaluation → chat verdict table → one commit or reset.
- Parallel implementer names must be English names only; names only, no character behavior.
- Do not parallelize tasks that touch the same files, migrations, shared state, or dependency graph.
- Never reset, retry, call Rem, or commit before showing the aggregated witch verdict table in chat.
- Never reset before death memory.
- Before every Return by Death reset, announce the exact death number in chat in English (for example: `Executing Return by Death #<number>.`).
- Never retry without new info.
- Dangerous ambiguity → ask 1 focused question.
