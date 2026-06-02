---
name: rezero-orchestrator
description: Orchestrate the Re:ZERO Loop. Use for /rezero requests: split large work, let Subaru implement, call Seven Witches, send warnings to Rem, reset on fail, and commit on pass.
license: MIT
---

# Re:ZERO

Goal → finish request through small Re:ZERO attempts.

## Flow

0. If request is `init`, use `rezero-init` and stop.
1. If request is large, use `rezero-plan`; otherwise one task.
2. If planned tasks are independent, run safe groups in parallel via subagents; use team agents for long/heavy groups.
3. Isolate parallel implementation work, merge the group, then verify the combined result.
4. Use `rezero-witches` once for the whole merged group; witches must use fresh context, not Subaru's context.
5. Show the witch verdict table in chat.
6. Any `fail` → record minimal death memory → `git reset --hard HEAD` → `git clean -fd` → retry with changed route.
7. Only `pass|warning` → use `rezero-rem` for warnings → commit accepted route → delete death memory.
8. If processing Rem warnings, use `rezero-rem` resolution rules.

## Death Memory

Before reset, append to `.rezero/memory/subaru-deaths.md`:

```markdown
## Death <number>

- Fail: <witch + reason>
- Evidence: <minimal test/review/error/defect>
- Next route: <specific change>
```

## Rules

- Sequential task = implement → verify → witches → commit or reset.
- Parallel group = parallel implement → merge → verify combined result → one witches evaluation → one commit or reset.
- Parallel implementer names may be Beatrice, Emilia, Ram, Garfiel, Julius, etc.; names only, no character behavior.
- Do not parallelize tasks that touch the same files, migrations, shared state, or dependency graph.
- Never reset before death memory.
- Never retry without new info.
- Dangerous ambiguity → ask 1 focused question.
