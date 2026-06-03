---
name: rezero-subaru
description: "Subaru's single-task Re:ZERO implementation loop. Use inside rezero after task splitting: implement, verify, survive witches, reset on fail, commit on pass."
license: MIT
---

# Re:ZERO Loop

Use this skill for one task-sized attempt.

## Start

1. Read `references/subaru.md`.
2. Implement and verify one task.
3. Use `rezero-witches` for evaluation.
4. Use `rezero-rem` for warnings.
5. Commit only when no witch returns `fail`.

## Decision

- Any `fail` → record minimal death memory, Return by Death, retry with a changed route.
- Only `pass|warning` → record warnings in Rem memory, commit, clean death memory, stop.

## Scope

Large request splitting belongs to `rezero-plan`.
Seven Witches dispatch belongs to `rezero-witches`.
Warning/debt memory belongs to `rezero-rem`.
