---
name: rezero-orchestrator
description: Orchestrate the Re:ZERO Loop. Use for /rezero requests: split large work, let Subaru implement, call Seven Witches, send warnings to Rem, reset on fail, and commit on pass.
license: MIT
---

# Re:ZERO

Goal → finish request through small Re:ZERO attempts.

## Flow

1. If request is large, use `rezero-plan`; otherwise one task.
2. For each task, follow `rezero-loop` / Subaru implementation rules.
3. After implementation and verification, use `rezero-witches`.
4. Show the witch verdict table in chat.
5. Any `fail` → record minimal death memory → `git reset --hard HEAD` → `git clean -fd` → retry with changed route.
6. Only `pass|warning` → use `rezero-rem` for warnings → commit accepted route → delete death memory.
7. If processing Rem warnings, use `rezero-rem` resolution rules.

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
- Never reset before death memory.
- Never retry without new info.
- Dangerous ambiguity → ask 1 focused question.
