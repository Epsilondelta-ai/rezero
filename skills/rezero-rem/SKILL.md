---
name: rezero-rem
description: Manage Re:ZERO warning memory. Use when witch warnings pass, when processing .rezero/memory/rem.md, or when resolved warnings should be removed.
license: MIT
---

# Re:ZERO Rem

Goal → preserve non-blocking witch warnings until they are resolved and accepted.

## Store Warnings

When a route passes with warnings:

- Append warnings to `.rezero/memory/rem.md`.
- Keep entries minimal and actionable.

```markdown
## Warning <number>

- Task: <request>
- Witch: <name>
- Warning: <short issue>
- Evidence: <command/output/file>
```

## Resolve Warnings

Treat Rem fixes as normal Re:ZERO attempts:

1. Pick warning(s) from `.rezero/memory/rem.md`.
2. Implement fixes.
3. Verify.
4. Run `rezero-witches`.
5. Commit only if no `fail`.
6. Delete resolved entries after the accepted commit.
7. Delete `.rezero/memory/rem.md` when no warnings remain.

## Rules

- Rem memory is not a bypass.
- Warnings stay until fixed, accepted, and committed.
- Do not delete unresolved warnings.
