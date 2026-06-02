[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | **Русский** | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop — агентный workflow, вдохновлённый **Return by Death** из **Re:Zero − Starting Life in Another World**.

Subaru реализует задачу, семь ведьм независимо проверяют результат, память о провале сохраняется, а попытка повторяется от `HEAD`.

## Установка

### Pi

```bash
pi install git:github.com/epsilondelta-ai/rezero
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

## Использование

```text
/rezero init
/rezero <task>
```

## Рабочий процесс

1. **Orchestrate** — Если запрос большой, `rezero-plan` разбивает его на малые задачи с критериями готовности. Независимые задачи можно выполнять параллельно через subagents/team agents.
2. **Implement** — Subaru выполняет последовательную задачу или параллельную группу от текущего `HEAD`; параллельная группа сначала сливается, затем проверяется как единый результат.
3. **Evaluate** — `rezero-witches` параллельно вызывает семь ведьм. Они используют fresh context и не наследуют контекст Subaru.
4. **Return by Death** — Любой `fail` записывает минимальную память о провале, выполняет reset/clean и повторяет попытку.
5. **Pass** — Только `pass`/`warning` проходят; warnings записываются в Rem memory, затем accepted route коммитится.
6. **Rem** — Warnings Rem также реализуются, проверяются, оцениваются ведьмами и коммитятся только без fail.

## Навыки

- `rezero-init` — setup witch evaluation tools.
- `rezero-orchestrator` — `/rezero` entrypoint.
- `rezero-plan` — large request splitting.
- `rezero-loop` — Subaru single-task loop.
- `rezero-witches` — fresh-context seven-witch review.
- `rezero-rem` — warning memory management.

## Концепции

### Natsuki Subaru

Subaru is the implementer. Starts from current `HEAD`, implements, verifies, and keeps only the memory needed to avoid repeating a failure.

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

Код умирает. Урок выживает.

### Seven Witches

![Witches' Tea Party](./images/witches-tea-party.webp)

| Witch | Focus | Example tools |
| --- | --- | --- |
| Echidna | Completeness, edge cases, coverage | SonarQube, coverage, Stryker |
| Typhon | Contracts, specs, public interfaces | typecheck, linter, Spectral, Pact |
| Minerva | User harm, regressions, runtime failures | tests, Playwright, Lighthouse CI, k6 |
| Daphne | Dependency/resource appetite | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Deceptive UI/docs/names/proof | screenshots, axe, lychee |
| Sekhmet | Maintainability, dead code, duplication | SonarQube, Knip, jscpd |
| Satella | Integration, security, policy, consistency | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem

![Rem](./images/rem.webp)

Rem — это память warnings.

## Лицензия

Distributed under the [MIT License](../LICENSE).
