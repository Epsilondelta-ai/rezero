---
name: rem
description: Track and manage technical debt that accumulates from evaluation warnings
---

# Rem — Technical Debt Tracker

Tracks and manages technical debt that accumulates when evaluations pass with warnings. Records debts in `rem.md`, prioritizes them, and verifies resolution.

> **Architecture note**: In the automated Re:ZERO Loop (`rezero.sh`), Rem runs as a **separate session** (Phase 4) after Satella commits the code. The session prompt at `prompts/rem.md` receives `{{EVALUATION_RESULTS}}` and `{{FINAL_VERDICT}}` from the orchestrator. This skill is for **manual invocation** when you want to inspect or manage technical debt directly.

## rem.md Format

```markdown
# Technical Debt Registry

## Unresolved

### REM-001: [Short description]
- **Source**: [Story ID] — [Story Title]
- **Reported by**: [Evaluator Name]
- **Severity**: LOW | MEDIUM | HIGH
- **Date**: [YYYY-MM-DD]
- **Details**: [What the issue is and why it matters]
- **Suggested Fix**: [How to resolve it]

## Resolved

### REM-001: [Short description]
- **Resolved**: [YYYY-MM-DD]
- **Resolution**: [What was done to fix it]
```

## Recording

When invoked after an evaluation with warnings:

1. Read `rem.md` (create if it doesn't exist).
2. Increment from the last `REM-XXX` ID.
3. For each WARN verdict, create an entry under `## Unresolved` with severity:
   - **HIGH**: Performance issues, potential bugs, security concerns, resource leaks
   - **MEDIUM**: Code quality issues, missing tests, pattern violations, duplication
   - **LOW**: Style issues, minor simplifications, documentation gaps

## Prioritization

When the agent starts an iteration and `rem.md` has unresolved items:

1. Sort by severity (HIGH first).
2. **HIGH** — Must resolve before any new story.
3. **MEDIUM** — Should resolve if related to code the next story touches.
4. **LOW** — May batch and resolve when convenient.

## Verification

When the agent resolves a debt item:

1. Review changes against the item's description.
2. Verify the fix doesn't introduce new issues.
3. If resolved: move to `## Resolved` with date and description.
4. If not fully resolved: keep in `## Unresolved` with updated note.

## Completion Check

After managing debt, check if the Re:ZERO Loop can be considered complete:

1. Read `task.json` — all stories must have `passes: true` (no `false` or `"blocked"` remaining).
2. Read `rem.md` — there must be no unresolved items.
3. If both conditions are met, the loop is `COMPLETE`.

## Integration

- **Before each iteration**: Check `rem.md`. HIGH items block new stories.
- **After each evaluation**: Record any warnings.
- **Completion**: Loop is `COMPLETE` only when all stories pass AND `rem.md` has no unresolved items.
