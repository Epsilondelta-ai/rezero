---
name: rezero-witches
description: Run the Seven Witches evaluation for a Re:ZERO attempt. Use after Subaru implements and verifies a task to get independent pass/warning/fail verdicts.
license: MIT
---

# Re:ZERO Witches

Goal → call seven independent reviewers and expose verdicts as a chat table.

## Inputs

Give each witch:

- Task/request.
- Current diff.
- Verification output.
- Relevant files or logs.
- Its own reference file from `references/witches/`.

## Witches

Call these as parallel subagents:

- `references/witches/echidna.md`
- `references/witches/typhon.md`
- `references/witches/minerva.md`
- `references/witches/daphne.md`
- `references/witches/carmilla.md`
- `references/witches/sekhmet.md`
- `references/witches/satella.md`

## Output

Show exactly one table in chat:

```markdown
| witch | verdict | reason | evidence |
|---|---|---|---|
| <name> | pass/warning/fail | <short reason> | <command/output/file> |
```

## Rules

- Verdict values only: `pass`, `warning`, `fail`.
- One `fail` kills the route.
- Warnings pass but must be sent to Rem.
- Keep evidence concise and reproducible.
- Witches judge only; they do not edit code.
- Each witch cleans resources it created before returning.
