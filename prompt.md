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

**Abort immediately and go to step 7 (Revert) if any of the following occur during implementation:**

- **Prerequisites missing**: A dependency, table, API, or module the story assumes does not exist.
- **Scope explosion**: The implementation is growing far beyond what a single iteration can handle.
- **Wrong approach**: The codebase structure differs from expectations, requiring a fundamentally different strategy.
- **Story too large**: The story cannot be completed within a single iteration and needs to be split. See [Story Splitting](#story-splitting).

Do not push through to evaluation when the implementation direction is clearly wrong. Revert early, record the reason, and let the next iteration course-correct.

#### Story Splitting

When a story is too large for a single iteration:

1. Revert all uncommitted changes.
2. Split the original story in `task.json`:
   - Replace the original story (set `"passes": "split"`) with smaller sub-stories.
   - Sub-stories use the original ID as prefix: `US-003` → `US-003-1`, `US-003-2`, etc.
   - Each sub-story must be completable in one iteration.
   - Assign priorities so sub-stories execute in dependency order.
3. Append to `progress.txt` why the split was needed and how it was divided.
4. Commit only the `task.json` and `progress.txt` changes.
5. End the iteration. The next iteration picks up the first sub-story.

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

**IMPORTANT: Always print the full evaluation results to the user in the following table format:**

```
| Evaluator | Domain       | Verdict | Assessment                  | Issues         |
|-----------|--------------|---------|-----------------------------|----------------|
| Echidna   | Completeness | PASS    | [1-3 sentence assessment]   | [issues or —]  |
| Minerva   | Regression   | PASS    | [1-3 sentence assessment]   | [issues or —]  |
| Sekhmet   | Efficiency   | WARN    | [1-3 sentence assessment]   | [issues or —]  |
| Typhon    | Integrity    | PASS    | [1-3 sentence assessment]   | [issues or —]  |
| Daphne    | Resources    | PASS    | [1-3 sentence assessment]   | [issues or —]  |
| Carmilla  | Alignment    | PASS    | [1-3 sentence assessment]   | [issues or —]  |

**Final Verdict**: PASS / FAIL
**Reason**: [Summary]
```

This table must be printed to the user every time the tea party runs. Do not skip or summarize it.

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

**IMPORTANT: Always print the following banner to the user when death regression is triggered:**

```
╔══════════════════════════════════════════════════════════╗
║                    사망회귀 (Death Regression)            ║
║                                                          ║
║  Story: [Story ID] - [Story Title]                       ║
║  Cause: [Brief reason for failure]                       ║
║  Attempt: [N] / {{MAX_DEATHS}}                           ║
╚══════════════════════════════════════════════════════════╝
```

This banner must be printed to the user every time a revert occurs. Do not skip or summarize it.

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

### Retry Limit

Each story has a maximum of **{{MAX_DEATHS}} attempts**. Count consecutive failures for the same story ID in `progress.txt`.

On the {{MAX_DEATHS}}th failure:
1. Mark the story as `"passes": "blocked"` in `task.json`.
2. Append a summary of all {{MAX_DEATHS}} attempts to `progress.txt`:

```
## [Date] - [Story ID]: BLOCKED
**Status**: Blocked after {{MAX_DEATHS}} failed attempts
**Attempt Summary**:
1. [Approach and failure reason]
...repeat for each attempt...
**Recommendation**: [What likely needs to change — story scope, prerequisites, or user input]
```

3. Skip this story and proceed to the next eligible story (one with no dependency on the blocked story).
4. If no eligible stories remain, respond with `<promise>BLOCKED</promise>` to signal that user intervention is needed.

## Principles

### Progress Tracking
- **Always append** to `progress.txt` — do not manually edit or delete existing entries.
- The loop automatically compresses older entries into one-line summaries between iterations, keeping the most recent entries in full detail. This prevents `progress.txt` from consuming excessive context.
- A **"Previous Iterations"** section contains compressed one-line summaries of older entries. Use these for high-level context; detailed learnings are preserved in full for recent iterations.
- Maintain a **"Codebase Patterns"** section at the top of `progress.txt` for reusable approaches. This section is preserved across compressions.

### Quality
- Never commit code that fails typecheck, lint, or tests.
- Every commit must leave the codebase in a working state.
- Frontend stories require browser verification before completion.

### Scope
- One story per iteration.
- Do not refactor unrelated code or add features beyond the story's scope.
- If a story is too large, split it directly in `task.json` (see [Story Splitting](#story-splitting)).

### Completion
- All stories `passes: true` AND no unresolved items in `rem.md` → `<promise>COMPLETE</promise>`.
- Otherwise, end normally to allow the next iteration.
