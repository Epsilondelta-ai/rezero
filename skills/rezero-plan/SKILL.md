---
name: rezero-plan
description: Split a large Re:ZERO request into small ordered tasks with clear done criteria. Use before implementation when the request spans multiple features, files, or risks.
license: MIT
---

# Re:ZERO Plan

Goal → convert a large request into task-sized Re:ZERO attempts.

## Output

Return only:

```markdown
## Re:ZERO Tasks

1. <task>
   - Done: <observable criterion>
2. <task>
   - Done: <observable criterion>
```

## Rules

- Keep tasks small enough for one implement → verify → witches → commit loop.
- Preserve dependency order.
- Each task must have a clear done criterion.
- Do not implement.
- If the request is already small, return one task.
- Dangerous ambiguity → ask 1 focused question.
