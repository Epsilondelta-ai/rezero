---
name: rezero-loop
description: Run a Re:ZERO-style implementation loop. Use when the user wants Subaru to implement, seven witches to review, fail to reset with preserved memory, and pass to commit.
license: MIT
---

# Re:ZERO Loop

Use this skill for implementation work that should follow Return by Death.

## Start

1. Read `references/subaru.md`.
2. Follow Subaru's flow exactly.
3. Keep runtime memory in the target repository under `.rezero/memory/`.

## Seven Witches

After Subaru verifies the work, call seven parallel subagents.
Give each subagent the changed diff, relevant verification output, and its own reference file:

- `references/witches/echidna.md`
- `references/witches/typhon.md`
- `references/witches/minerva.md`
- `references/witches/daphne.md`
- `references/witches/carmilla.md`
- `references/witches/sekhmet.md`
- `references/witches/satella.md`

Each witch returns only:

```markdown
| witch | verdict | reason | evidence |
|---|---|---|---|
| <name> | pass/warning/fail | <short reason> | <command/output/file> |
```

## Decision

- Any `fail` → Subaru records minimal death memory, runs Return by Death, and retries.
- Only `pass|warning` → Subaru records warnings in Rem memory, commits, cleans death memory, and stops.
