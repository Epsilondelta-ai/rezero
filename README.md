**English** | [한국어](./docs/README.ko.md) | [简体中文](./docs/README.zh-CN.md) | [日本語](./docs/README.ja.md) | [Español](./docs/README.es.md) | [Português (BR)](./docs/README.pt-BR.md) | [Français](./docs/README.fr.md) | [Русский](./docs/README.ru.md) | [Deutsch](./docs/README.de.md)

# Re:ZERO Loop

![](./docs/images/rezero.webp)

> Re:ZERO Loop is an agent workflow inspired by **Return by Death** from **Re:Zero − Starting Life in Another World**.

It lets Subaru implement work, sends the result to seven independent witches for review, preserves failure memory, and retries from `HEAD` when the route fails.

## Table of Contents

- [Installation](#installation)
  - [Pi](#pi)
  - [Claude Code](#claude-code)
  - [Codex](#codex)
- [Usage](#usage)
- [Workflow](#workflow)
- [Skills](#skills)
- [Concepts](#concepts)
  - [Natsuki Subaru](#natsuki-subaru)
  - [Return by Death](#return-by-death)
  - [Seven Witches](#seven-witches)
  - [Rem](#rem)
- [License](#license)

## Installation

### Pi

```bash
pi install git:github.com/epsilondelta-ai/rezero
```

Local development:

```bash
pi install /path/to/rezero
```

### Claude Code

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero@rezero-marketplace
```

### Codex

```bash
codex plugin marketplace add epsilondelta-ai/rezero
```

Then open `/plugins`, install `rezero`, and start a new session.

## Usage

Initialize witch evaluation tools in a target repository:

```text
/rezero init
```

Run the loop:

```text
/rezero <task>
```

Example:

```text
/rezero Add user profile editing with validation and tests
```

## Workflow

0. **Init**
   - `/rezero init` detects the repository stack.
   - It configures fitting witch evaluation tools, keeps `.rezero/memory/` ignored, verifies available tools, and writes `.rezero/tools.md`.
   - Tools that require accounts or external services are recorded as setup notes instead of being faked.

1. **Orchestrate**
   - `/rezero` loads `rezero-orchestrator`.
   - Large requests are split by `rezero-plan` into ordered tasks with done criteria.
   - Independent tasks may run in parallel through subagents or team agents.

2. **Implement**
   - Subaru runs one sequential task or one parallel task group from current `HEAD`.
   - Parallel groups are merged first, then verified as one combined result.

3. **Evaluate**
   - `rezero-witches` calls all seven witches in parallel.
   - Witches use fresh context, not Subaru's context, to avoid confirmation bias.
   - Chat shows one verdict table:

```markdown
| witch | verdict | reason | evidence |
|---|---|---|---|
| Echidna | pass/warning/fail | <short reason> | <command/output/file> |
```

4. **Return by Death**
   - Any `fail` kills the route.
   - Subaru writes minimal failure memory to `.rezero/memory/subaru-deaths.md`:

```markdown
## Death <number>

- Fail: <witch + reason>
- Evidence: <minimal test/review/error/defect>
- Next route: <specific change>
```

   - Then resets:

```bash
git reset --hard HEAD
git clean -fd
```

   - `.rezero/memory/` is ignored, so failure memory survives.

5. **Pass**
   - Only `pass` and `warning` verdicts pass.
   - Warnings are stored by `rezero-rem` in `.rezero/memory/rem.md`.
   - Accepted route is committed.
   - `.rezero/memory/subaru-deaths.md` is deleted after commit.

6. **Rem**
   - Rem warnings are normal Re:ZERO attempts.
   - They must be implemented, verified, evaluated by witches, and committed with no `fail`.
   - When all warnings are resolved and accepted, `.rezero/memory/rem.md` is deleted.

## Skills

- `rezero-init` — detects the stack and sets up witch evaluation tools for `/rezero init`.
- `rezero-orchestrator` — `/rezero` entrypoint; coordinates the full loop.
- `rezero-plan` — splits large requests into small ordered tasks.
- `rezero-loop` — Subaru's single-task implementation loop.
- `rezero-witches` — dispatches seven fresh-context witch reviews and prints the verdict table.
- `rezero-rem` — stores, resolves, and deletes warning memory.

## Concepts

### Natsuki Subaru

Subaru is the implementer.

- Starts from current `HEAD`.
- Implements and verifies the task.
- Calls the witches after work is complete.
- If the route fails, keeps only the memory needed to avoid the same failure.

### Return by Death

![Natsuki Subaru](./docs/images/subaru.webp)

Return by Death resets the working tree but preserves failure memory.

```bash
git reset --hard HEAD
git clean -fd
```

The code dies. The lesson survives.

### Seven Witches

![Witches' Tea Party](./docs/images/witches-tea-party.webp)

The witches are independent reviewers. They do not inherit Subaru's reasoning, plan, self-assessment, or prior failed route unless required as evidence.

| Witch | Focus | Example tools |
| --- | --- | --- |
| Echidna (Greed) | Completeness, edge cases, coverage, quality gates | SonarQube/SonarCloud, coverage, Stryker |
| Typhon (Pride) | Contracts, specs, public interfaces, user intent | typecheck, linter, Spectral, Pact |
| Minerva (Wrath) | User harm, regressions, runtime failures | full tests, Playwright, Lighthouse CI, k6 |
| Daphne (Gluttony) | Dependency/resource appetite | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla (Lust) | Deceptive UI/docs/names/proof | Playwright screenshots, axe, lychee |
| Sekhmet (Sloth) | Maintainability, dead code, duplication, complexity | SonarQube/SonarCloud, Knip, jscpd |
| Satella (Envy) | Integration, security, policy, project consistency | CodeQL, Gitleaks, Trivy, full CI |

Verdicts:

- `pass` — accepted.
- `warning` — accepted, recorded by Rem.
- `fail` — rejected; triggers Return by Death.

### Rem

![Rem](./docs/images/rem.webp)

Rem is warning memory.

- Warnings that pass review are stored in `.rezero/memory/rem.md`.
- They remain until fixed, re-evaluated by witches, accepted, and committed.
- When no warnings remain, `rem.md` is deleted.

## License

This project is distributed under the [MIT License](./LICENSE).
