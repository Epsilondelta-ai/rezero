---
name: rezero-init
description: "Initialize a repository for Re:ZERO Loop. Use for `/rezero:run init`: detect project type, set up witch evaluation tools, create memory ignore rules, and record unavailable tools."
license: MIT
---

# Re:ZERO Init

Goal → prepare the target repository so witches can evaluate with real tools.

## Flow

1. Detect project type from files: package manager, language, framework, test runner, CI, container/IaC.
2. Ensure `.rezero/memory/` is ignored by git.
3. Install or configure only tools that fit the project.
4. Prefer project-local dev dependencies over global installs.
5. If a tool needs a service, prefer a local/self-hosted setup (for example Docker Compose) over SaaS accounts or external tokens; write setup notes instead of faking readiness.
6. Verify installed tools with version/help commands.
7. Write `.rezero/tools.md` with the init marker, installed tools, skipped tools, commands, local services, and required env.

## Baseline Tools

Use when applicable:

- Echidna/Sekhmet → local self-hosted SonarQube (Docker Compose + scanner) or project-native quality gate. Do not require SonarCloud/SaaS tokens by default.
- Typhon → typecheck, linter, Spectral for OpenAPI, Pact for service contracts.
- Minerva → project tests, Playwright for web flows, Lighthouse CI for web perf, k6 for service load.
- Daphne → OSV-Scanner, Knip for JS/TS dependency hygiene, source-map-explorer for web bundles, hyperfine for CLI/runtime benchmarks.
- Carmilla → Playwright screenshots, axe for accessibility, lychee for docs links.
- Satella → CodeQL, Gitleaks, Trivy, full CI/local equivalent.

## Local Tool and Service Defaults

- SonarQube → when configured, prefer a repository-local compose file such as `.rezero/sonarqube.compose.yaml` with `sonarqube:lts-community` and Postgres, started via `docker compose -f .rezero/sonarqube.compose.yaml up -d`.
- SonarQube URL → record `http://localhost:9000`, first-login credentials (`admin` / `admin`), and the scanner command in `.rezero/tools.md`.
- SonarQube tokens → only mention a token generated from the local self-hosted instance (for scanner auth); never describe SonarCloud or an external token as the default path.
- Lighthouse CI → local CLI by default (`lhci collect`/`lhci assert`); a dashboard server is optional and should be local/self-hosted if needed.
- k6 → local CLI or Docker image by default; do not require k6 Cloud.
- Pact → local contract tests by default; Pact Broker is optional and should be local/self-hosted if needed.
- Spectral, Knip, source-map-explorer, axe, lychee → project-local CLI/dev dependency by default.
- CodeQL, Gitleaks, Trivy → local CLI/container scan by default; GitHub/code-scanning uploads or SaaS dashboards are optional and require explicit approval.
- OSV-Scanner → local CLI, but it may query the public OSV API unless an offline vulnerability database is configured; record that network dependency explicitly instead of calling it a token-required service.

## Stack Selection

- Frontend/web → Playwright, axe, Lighthouse CI, source-map-explorer, web test runner.
- Backend/API → typecheck/linter, API contract/schema tools, k6, CodeQL, Gitleaks, Trivy, OSV-Scanner.
- Script/CLI → shellcheck or language linter, golden output tests, hyperfine, Gitleaks, OSV-Scanner.
- No matching stack → configure git ignore and `.rezero/tools.md`; ask one focused question before installing.

## Output

Create or update `.rezero/tools.md`:

```markdown
# Re:ZERO Tools

<!-- rezero-init: v0.1.0 -->

## Detected Stack

- <stack evidence>

## Installed/Configured

- <witch>: <tool> — <command>

## Skipped

- <tool> — <reason or required setup>

## Local Services

- <service> — <docker compose up command, docker compose down command, URL, default credentials, scanner command>

## Required Environment

- <local env/service config if needed; avoid SaaS tokens unless explicitly approved>
```

## Rules

- Do not install every possible tool.
- For SonarQube, configure a local self-hosted instance (for example `compose.yaml` service + `sonar-scanner`) when feasible; `.rezero/tools.md` must not describe it as an external token-only tool.
- For any tool with both self-hosted/local and SaaS modes, prefer the self-hosted/local mode by default.
- Do not label tools as `external service/token required` when a local CLI, local Docker image, or self-hosted service is the supported default.
- If an evaluation requires starting a Docker Compose service, record the matching shutdown command in `.rezero/tools.md` and ensure the service is stopped after the evaluation finishes.
- Do not add SaaS services or account-backed integrations without user approval.
- Do not mark unavailable tools as ready.
- Keep generated config minimal and project-specific.
- `.rezero/tools.md` must include `<!-- rezero-init: v0.1.0 -->`.
- Commit only if the caller requested normal Re:ZERO commit behavior; init itself may be committed by the caller.
