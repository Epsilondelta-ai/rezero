---
name: rezero-init
description: Initialize a repository for Re:ZERO Loop. Use for `/rezero init`: detect project type, set up witch evaluation tools, create memory ignore rules, and record unavailable tools.
license: MIT
---

# Re:ZERO Init

Goal → prepare the target repository so witches can evaluate with real tools.

## Flow

1. Detect project type from files: package manager, language, framework, test runner, CI, container/IaC.
2. Ensure `.rezero/memory/` is ignored by git.
3. Install or configure only tools that fit the project.
4. Prefer project-local dev dependencies over global installs.
5. If a tool needs external auth/service, write setup notes instead of faking readiness.
6. Verify installed tools with version/help commands.
7. Write `.rezero/tools.md` with installed tools, skipped tools, commands, and required env.

## Baseline Tools

Use when applicable:

- Echidna/Sekhmet → SonarQube/SonarCloud scanner or project-native quality gate.
- Typhon → typecheck, linter, Spectral for OpenAPI, Pact for service contracts.
- Minerva → project tests, Playwright for web flows, Lighthouse CI for web perf, k6 for service load.
- Daphne → OSV-Scanner, Knip for JS/TS dependency hygiene, source-map-explorer for web bundles, hyperfine for CLI/runtime benchmarks.
- Carmilla → Playwright screenshots, axe for accessibility, lychee for docs links.
- Satella → CodeQL, Gitleaks, Trivy, full CI/local equivalent.

## Stack Selection

- Frontend/web → Playwright, axe, Lighthouse CI, source-map-explorer, web test runner.
- Backend/API → typecheck/linter, API contract/schema tools, k6, CodeQL, Gitleaks, Trivy, OSV-Scanner.
- Script/CLI → shellcheck or language linter, golden output tests, hyperfine, Gitleaks, OSV-Scanner.
- No matching stack → configure git ignore and `.rezero/tools.md`; ask one focused question before installing.

## Output

Create or update `.rezero/tools.md`:

```markdown
# Re:ZERO Tools

## Detected Stack

- <stack evidence>

## Installed/Configured

- <witch>: <tool> — <command>

## Skipped

- <tool> — <reason or required setup>

## Required Environment

- <env/service/token if needed>
```

## Rules

- Do not install every possible tool.
- Do not add services that need accounts without user approval.
- Do not mark unavailable tools as ready.
- Keep generated config minimal and project-specific.
- Commit only if the caller requested normal Re:ZERO commit behavior; init itself may be committed by the caller.
