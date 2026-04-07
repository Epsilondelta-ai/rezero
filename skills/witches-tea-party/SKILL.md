---
name: witches-tea-party
description: Evaluate code changes from six perspectives (Echidna, Minerva, Sekhmet, Typhon, Daphne, Carmilla)
---

# Witches' Tea Party — Code Evaluation

Evaluates code changes from six perspectives after implementation. Produces a structured verdict: PASS, WARN, or FAIL per evaluator, then a final judgment.

> **Architecture note**: In the automated Re:ZERO Loop (`rezero.sh`), each witch runs as a **separate parallel session** using prompts in `prompts/witches/`. Satella (`prompts/witches/satella.md`) aggregates results and handles commit/revert. Rem (`prompts/rem.md`) records warnings as technical debt. This skill is for **manual single-session evaluation** when you want to run all six checks at once.

## Process

### Step 1: Gather Context

- The story description and its acceptance criteria
- The git diff of all changes
- Results of typecheck, linter, and test suite
- List of files modified

### Step 2: Run Six Evaluations

For each evaluator, output:

```
### [Name] — [Domain]
**Verdict**: PASS | WARN | FAIL
**Assessment**: [1-3 sentences]
**Issues** (if any):
- [Specific issue]
```

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

### Step 3: Final Judgment

Aggregate all six evaluations:

```
### Final Judgment

| Evaluator | Verdict |
|-----------|---------|
| Echidna   | PASS/WARN/FAIL |
| Minerva   | PASS/WARN/FAIL |
| Sekhmet   | PASS/WARN/FAIL |
| Typhon    | PASS/WARN/FAIL |
| Daphne    | PASS/WARN/FAIL |
| Carmilla  | PASS/WARN/FAIL |

**Verdict**: PASS / FAIL
**Reason**: [Summary]
```

Aggregation rules depend on **difficulty** (default: `easy`):

- **Easy**: 3+ FAILs needed for overall `FAIL`. 1-2 FAILs are downgraded to `WARN`. Witches evaluate with more leniency.
- **Hard**: Any single `FAIL` -> overall `FAIL`. Witches evaluate with full rigor.

### Output Format (for automated parsing)

When used by the automated loop, each witch outputs exactly these three lines at the end:

```
[VERDICT] PASS or WARN or FAIL
[ASSESSMENT] Your 1-3 sentence assessment on a single line
[ISSUES] Specific issues found, or — if none
```
