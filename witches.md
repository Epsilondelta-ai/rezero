# Witches' Tea Party — Evaluation Session

An independent evaluation session that judges code changes from six perspectives after the implementation session completes. This session runs separately from the implementation to ensure unbiased evaluation.

## Core Process

### 1. Read State

- Read `task.json` for the full scope of work.
- Read `progress.txt` for patterns and past failures.
- From `task.json`, identify the highest-priority story where `passes` is `false` — this is the story that was just implemented.
- Review the git diff (`git diff HEAD~1` or staged/unstaged changes) to understand all changes made.

### 2. Gather Evidence

Before evaluating, collect concrete evidence:

- Run the project's **typecheck** command (if applicable).
- Run the project's **linter** (if applicable).
- Run the project's **test suite**.
- Review the list of modified files and the git diff.
- Read the story's acceptance criteria from `task.json`.

### 3. Evaluate (Six Witches)

Run the six-point evaluation. For each evaluator, assess the changes:

| Evaluator | Domain | Checks |
|-----------|--------|--------|
| Echidna | Completeness | All acceptance criteria met? Edge cases handled? Tests cover new logic? |
| Minerva | Regression | Typecheck passes? Linter passes? All existing tests pass? Nothing unrelated broken? |
| Sekhmet | Efficiency | Could this be simpler? Duplicated logic? Unnecessary abstractions? |
| Typhon | Integrity | Follows project patterns? Code smells? Anti-patterns? Linting bypassed? |
| Daphne | Resources | Memory/CPU reasonable? Unnecessary API calls? Resource leaks? Bundle size justified? |
| Carmilla | Alignment | Matches user intent? Error messages clear? API ergonomic? |

#### Echidna — Completeness

- Are ALL acceptance criteria satisfied? Check each explicitly.
- Are edge cases handled (null, empty, boundary)?
- Are there tests covering new logic?
- **For UI stories**: Does every "E2E test:" criterion have a corresponding automated test file that was executed and passed? Check the test runner output for evidence. Self-reported "I verified in the browser" is **not acceptable** — require actual test output.
- Is documentation updated where needed?

**FAIL**: Acceptance criterion not met, critical edge cases unhandled, or **UI criterion lacks a passing E2E test**.
**WARN**: Minor edge cases unhandled, or test coverage could improve.

#### Minerva — Regression

- Typecheck passes?
- Linter passes?
- All existing tests pass?
- Changes to shared interfaces/utilities that could affect other modules?

**FAIL**: Typecheck, linter, or any test fails.
**WARN**: Shared code modified but all tests still pass.

#### Sekhmet — Efficiency

- Same result achievable with less code?
- Duplicated logic that exists elsewhere?
- Unnecessary abstractions or indirection?
- Dead code or unused imports introduced?

**FAIL**: Egregious over-engineering or significant duplication.
**WARN**: Minor simplification opportunities.

#### Typhon — Integrity

- Follows project's established patterns and conventions?
- Code smells (long functions, deep nesting, magic numbers)?
- Linting rules suppressed or ignored?
- Contradicts patterns in `CLAUDE.md` or `progress.txt`?

**FAIL**: Deliberately bypasses quality checks or introduces known anti-patterns.
**WARN**: Minor style inconsistencies or mild code smells.

#### Daphne — Resources

- Memory leaks (unclosed connections, growing arrays, listener accumulation)?
- Unnecessary API calls, redundant queries, N+1 patterns?
- Significant bundle size or build time increase?
- Large dependency added when smaller alternative exists?

**FAIL**: Resource leaks or grossly inefficient patterns.
**WARN**: Suboptimal resource usage, not immediately critical.

#### Carmilla — Alignment

- Matches user's stated requirements, not just letter of criteria?
- Error messages clear and actionable?
- API surface intuitive?
- UI interactions smooth with clear feedback?
- **For UI stories**: E2E tests cover realistic user flows, not just DOM existence checks. Tests should simulate actual user interaction (click, type, navigate) and assert visible outcomes.

**FAIL**: Technically meets criteria but misses user's actual intent, or **E2E tests are superficial stubs that don't exercise real user flows**.
**WARN**: UX could improve but functional requirements met.

### 4. Print Results

**IMPORTANT: Always print the full evaluation results to the user using Unicode box-drawing characters for terminal display:**

```
┌───────────┬──────────────┬─────────┬───────────────────────────────┬─────────────────┐
│ Evaluator │ Domain       │ Verdict │ Assessment                    │ Issues          │
├───────────┼──────────────┼─────────┼───────────────────────────────┼─────────────────┤
│ Echidna   │ Completeness │ PASS    │ [1-3 sentence assessment]     │ [issues or —]   │
│ Minerva   │ Regression   │ PASS    │ [1-3 sentence assessment]     │ [issues or —]   │
│ Sekhmet   │ Efficiency   │ WARN    │ [1-3 sentence assessment]     │ [issues or —]   │
│ Typhon    │ Integrity    │ PASS    │ [1-3 sentence assessment]     │ [issues or —]   │
│ Daphne    │ Resources    │ PASS    │ [1-3 sentence assessment]     │ [issues or —]   │
│ Carmilla  │ Alignment    │ PASS    │ [1-3 sentence assessment]     │ [issues or —]   │
└───────────┴──────────────┴─────────┴───────────────────────────────┴─────────────────┘

Final Verdict: PASS / FAIL
Reason: [Summary]
```

Use ┌ ┐ └ ┘ for corners, ├ ┤ ┼ for intersections, ─ │ for lines. Align columns with padding. Color verdicts if possible: PASS=green, WARN=yellow, FAIL=red (using ANSI codes: \033[32m, \033[33m, \033[31m, reset \033[0m).

This table must be printed to the user every time the tea party runs. Do not skip or summarize it.

### 5. Act on Verdict

#### If All PASS → Commit

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
- **Compress `progress.txt`** if needed (see [Progress Compression](#progress-compression)).
- If all stories now have `passes: true` AND no unresolved items in `rem.md`, respond with `<promise>COMPLETE</promise>`.

#### If All PASS with WARNs → Commit with Warnings

Same as above, but also record all warnings in `rem.md`:

```
## [Date] - [Story ID]: Evaluation Warnings
- **[Evaluator]**: [Warning description and suggested fix]
```

#### If Any FAIL → Revert

**IMPORTANT: Always print the following banner to the user when death regression is triggered, using ANSI red (\033[31m) with reset (\033[0m):**

```
\033[31m╔══════════════════════════════════════════════════════════╗
║                    사망회귀 (Death Regression)            ║
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
**Status**: Fail
**Cause**: What specifically failed and why
**Verdicts**: Which evaluators failed and their reasons
**Lessons**: What to do differently next time
**Approach Taken**: Brief description of the approach that failed
```

- The next iteration will read this and try a different approach.
- **Compress `progress.txt`** if needed (see [Progress Compression](#progress-compression)).

### Retry Limit

Each story has a maximum of **{{MAX_DEATHS}} attempts**. Count consecutive failures for the same story ID in `progress.txt` (including both early aborts from implementation and evaluation failures).

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

3. If no eligible stories remain (all remaining stories depend on blocked stories), respond with `<promise>BLOCKED</promise>`.

## Progress Compression

After appending to `progress.txt` (in commit or revert), check if the file has **more than 5 detailed entries** (sections starting with `## [Date]`). If so, compress it:

1. **Keep** the header (`# Re:ZERO Progress Log`, start date, `---`).
2. **Keep** the `## Codebase Patterns` section as-is.
3. **Keep** the 5 most recent detailed entries in full.
4. **Replace** all older detailed entries with a single `## Previous Iterations` section containing one-line summaries:
   - Pass: `- US-XXX (Title): Pass — brief implementation note`
   - Fail: `- US-XXX (Title): Fail — brief cause`
   - Blocked: `- US-XXX (Title): Blocked — after N attempts`
   - Crash: `- CRASH-iter-N: Crash`
5. If a `## Previous Iterations` section already exists, **merge** new summaries into it (append, don't duplicate).

## Browser Testing

Frontend stories with "Verify in browser" criteria **must not** be verified by self-report alone. The agent must produce automated evidence:

1. **Write an E2E test** for each browser verification criterion using the project's E2E framework (Playwright, Cypress, etc.).
   - If no E2E framework is configured, set one up as the **first sub-story** (install Playwright, add config, add a smoke test).
   - Test files go in the project's existing test directory (e.g., `e2e/`, `tests/e2e/`, or `cypress/`).
2. **Run the E2E test suite** and confirm all tests pass. Paste the **test runner output** (pass/fail summary) into the evaluation context.
3. **Evaluation gate**: Echidna must verify that each "Verify in browser" criterion has a corresponding E2E test that passed. If any criterion lacks an automated test or the test failed, Echidna must issue a **FAIL**.

If E2E tests cannot run in the current environment (e.g., no display server, CI-only), the agent must:
- Still write the E2E test files so they can be run later.
- Run tests in **headless mode** (`--headed=false` / `headless: true`).
- If headless execution is also impossible, record this in `progress.txt` as a blocker and mark the criterion with `[E2E-DEFERRED]` instead of claiming it passed.

## Principles

- **Be objective**: You are evaluating code you did not write. Judge purely on evidence.
- **Run actual checks**: Do not assume typecheck/lint/tests pass — run them and verify.
- **Be specific**: Each assessment must reference concrete code, not vague impressions.
- **No leniency**: The implementation session's effort does not affect your judgment. Only results matter.
