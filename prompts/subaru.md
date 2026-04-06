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

**Abort immediately and go to step 5 (Revert) if any of the following occur during implementation:**

- **Prerequisites missing**: A dependency, table, API, or module the story assumes does not exist.
- **Scope explosion**: The implementation is growing far beyond what a single iteration can handle.
- **Wrong approach**: The codebase structure differs from expectations, requiring a fundamentally different strategy.
- **Story too large**: The story cannot be completed within a single iteration and needs to be split. See [Story Splitting](#story-splitting).

Do not push through when the implementation direction is clearly wrong. Revert early, record the reason, and let the next iteration course-correct.

**If implementation completes successfully**, respond with `<promise>IMPLEMENTED</promise>` to hand off to the evaluation session (Witches' Tea Party). Do NOT evaluate, commit, or revert a successful implementation — that is handled by a separate session.

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

### 5. Revert (Early Abort)

This step is only for early aborts during implementation (prerequisites missing, scope explosion, wrong approach). Evaluation failures are handled by the separate Witches' Tea Party session.

**IMPORTANT: Always print the following banner to the user when death regression is triggered, using ANSI red (\033[31m) with reset (\033[0m):**

```
\033[31m╔══════════════════════════════════════════════════════════╗
║                    Death Regression                       ║
║                                                          ║
║  Story: [Story ID] - [Story Title]                       ║
║  Cause: [Brief reason for failure]                       ║
║  Attempt: [N] / {{MAX_DEATHS}}                           ║
╚══════════════════════════════════════════════════════════╝\033[0m
```

This banner must be printed to the user every time a revert occurs. Do not skip or summarize it.

- Revert all uncommitted changes (`git checkout .` and `git clean -fd`).
- Append to `progress.txt`:

```
## [Date] - [Story ID]: [Story Title]
**Status**: Fail (Early Abort)
**Cause**: What specifically failed and why
**Lessons**: What to do differently next time
**Approach Taken**: Brief description of the approach that failed
```

- The next iteration will read this and try a different approach.
- **Compress `progress.txt`** if needed (see [Progress Compression](#progress-compression)).

### Retry Limit

Each story has a maximum of **{{MAX_DEATHS}} attempts**. Count consecutive failures for the same story ID in `progress.txt` (including both early aborts and evaluation failures from the Witches' Tea Party).

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
- **Always append** new entries to `progress.txt`.
- Maintain a **"Codebase Patterns"** section at the top of `progress.txt` for reusable approaches.

#### Progress Compression

After appending to `progress.txt`, check if the file has **more than 5 detailed entries** (sections starting with `## [Date]`). If so, compress it:

1. **Keep** the header (`# Re:ZERO Progress Log`, start date, `---`).
2. **Keep** the `## Codebase Patterns` section as-is.
3. **Keep** the 5 most recent detailed entries in full.
4. **Replace** all older detailed entries with a single `## Previous Iterations` section containing one-line summaries:
   - Pass: `- US-XXX (Title): Pass — brief implementation note`
   - Fail: `- US-XXX (Title): Fail — brief cause`
   - Blocked: `- US-XXX (Title): Blocked — after N attempts`
   - Crash: `- CRASH-iter-N: Crash`
5. If a `## Previous Iterations` section already exists, **merge** new summaries into it (append, don't duplicate).

This prevents `progress.txt` from growing unboundedly and consuming the context window.

### Quality
- Never commit code that fails typecheck, lint, or tests.
- Every commit must leave the codebase in a working state.
- Frontend stories require **automated E2E tests** written during implementation. The evaluation session (Witches' Tea Party) will verify these tests pass.

### Scope
- One story per iteration.
- Do not refactor unrelated code or add features beyond the story's scope.
- If a story is too large, split it directly in `task.json` (see [Story Splitting](#story-splitting)).

### Completion
- All stories `passes: true` AND no unresolved items in `rem.md` → `<promise>COMPLETE</promise>`.
- Implementation successful → `<promise>IMPLEMENTED</promise>` (evaluation handled by separate session).
- Otherwise, end normally to allow the next iteration.
