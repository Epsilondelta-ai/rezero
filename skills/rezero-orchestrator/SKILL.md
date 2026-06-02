---
name: rezero-orchestrator
description: Orchestrate the Re:ZERO Loop. Use for /rezero requests: split large work, let Subaru implement, call Seven Witches, send warnings to Rem, reset on fail, and commit on pass.
license: MIT
---

# Re:ZERO

Goal → finish request through small Re:ZERO attempts.

## Flow

1. If request is large, use `rezero-plan`; otherwise one task.
2. If planned tasks are independent, run safe groups in parallel via subagents; use team agents for long/heavy groups.
3. Isolate parallel implementation work, merge one accepted task at a time, then follow `rezero-loop` / Subaru rules.
4. After implementation and verification, use `rezero-witches`.
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

- One task = implement → verify → witches → commit or reset.
- Parallel tasks still need independent witches verdicts and separate accepted commits.
- Do not parallelize tasks that touch the same files, migrations, shared state, or dependency graph.
- Never reset before death memory.
- Never retry without new info.
- Dangerous ambiguity → ask 1 focused question.
