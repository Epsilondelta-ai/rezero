# Re:ZERO Loop — Agent Directive

An autonomous agent that implements user stories from `task.json` one at a time, accumulating knowledge across iterations. Each iteration starts with a fresh context, carrying state only through `progress.txt` and the codebase.

## Core Loop

### 1. Read State

- Read `task.json` for the full scope of work.
- Read `progress.txt` for patterns, past failures, and lessons from previous iterations.
- Verify you are on the git branch specified in `task.json`.

### 2. Resolve Technical Debt

- Check if `rem.md` exists and contains unresolved items.
- If it does, **resolve these items before picking up any new story**.
- Mark resolved items as done, then proceed.

### 3. Select Story

- From `task.json`, select the highest-priority story where `passes` is `false`.
- If all stories have `passes: true`, respond with `<promise>COMPLETE</promise>`.
- **One story per iteration.** Do not attempt multiple.

### 4. Implement

- Implement the story according to its description and acceptance criteria.
- Write clean, minimal code. No over-engineering or unnecessary abstractions.
- Follow existing codebase patterns from `progress.txt` and nearby `CLAUDE.md` files.

### 5. Evaluate

Run the six-point evaluation after implementation:

| Evaluator | Domain | Checks |
|-----------|--------|--------|
| Echidna | Completeness | All acceptance criteria met? Edge cases handled? Tests cover new logic? |
| Minerva | Regression | Typecheck passes? Linter passes? All existing tests pass? Nothing unrelated broken? |
| Sekhmet | Efficiency | Could this be simpler? Duplicated logic? Unnecessary abstractions? |
| Typhon | Integrity | Follows project patterns? Code smells? Anti-patterns? Linting bypassed? |
| Daphne | Resources | Memory/CPU reasonable? Unnecessary API calls? Resource leaks? Bundle size justified? |
| Carmilla | Alignment | Matches user intent? Error messages clear? API ergonomic? |

**Verdict**:
- **All PASS** → Go to step 6 (Commit).
- **Any FAIL** → Go to step 7 (Revert).
- **All PASS with WARNs** → Go to step 6, but record warnings in `rem.md`.

### 6. Commit

- Set `"passes": true` for the story in `task.json`.
- Commit all changes with a message referencing the story ID.
- Append to `progress.txt`:

```
## [Date] - [Story ID]: [Story Title]
**Status**: Pass
**Implementation**: Brief description of what was done
**Files Changed**: List of modified files
**Patterns Learned**: Any reusable patterns discovered
**Warnings**: Any warnings from evaluation (if applicable)
```

- Update nearby `CLAUDE.md` files with reusable knowledge (module patterns, API conventions, testing approaches). No story-specific details.
- If evaluation produced warnings, record them in `rem.md`.

### 7. Revert

- Revert all uncommitted changes (`git checkout .` and `git clean -fd`).
- Append to `progress.txt`:

```
## [Date] - [Story ID]: [Story Title]
**Status**: Fail
**Cause**: What specifically failed and why
**Verdicts**: Which evaluators failed and their reasons
**Lessons**: What to do differently next time
**Approach Taken**: Brief description of the approach that failed
```

- The next iteration will read this and try a different approach.

## Principles

### Progress Tracking
- **Never replace** `progress.txt` — always append.
- Maintain a **"Codebase Patterns"** section at the top of `progress.txt` for reusable approaches.

### Quality
- Never commit code that fails typecheck, lint, or tests.
- Every commit must leave the codebase in a working state.
- Frontend stories require browser verification before completion.

### Scope
- One story per iteration.
- Do not refactor unrelated code or add features beyond the story's scope.
- If a story is too large, note this in `progress.txt` and suggest splitting it.

### Completion
- All stories `passes: true` AND no unresolved items in `rem.md` → `<promise>COMPLETE</promise>`.
- Otherwise, end normally to allow the next iteration.
