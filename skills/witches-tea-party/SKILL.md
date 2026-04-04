# Witches' Tea Party — Code Evaluation

Evaluates code changes from six perspectives after implementation. Produces a structured verdict: PASS, WARN, or FAIL per evaluator, then a final judgment.

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
- Is documentation updated where needed?

**FAIL**: Acceptance criterion not met, or critical edge cases unhandled.
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

**FAIL**: Technically meets criteria but misses user's actual intent.
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

- **Any FAIL** → `FAIL`. Agent must revert and retry.
- **All PASS, no warnings** → `PASS`.
- **All PASS with WARNs** → `PASS`, but warnings recorded in `rem.md`.

### Step 4: Record Warnings

If PASS with warnings, output `rem.md` entries:

```
## [Date] - [Story ID]: Evaluation Warnings
- **[Evaluator]**: [Warning description and suggested fix]
```
