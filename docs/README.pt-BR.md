[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | **Português (BR)** | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop é um fluxo de agentes inspirado em **Return by Death** de **Re:Zero − Starting Life in Another World**.

Subaru implementa, sete bruxas revisam de forma independente, a memória de falha é preservada e a tentativa recomeça de `HEAD`.

## Instalação

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

## Uso

```text
/rezero init
/rezero <task>
```

## Fluxo de trabalho

1. **Orchestrate** — Se o pedido for grande, `rezero-plan` divide em tarefas pequenas com critérios de conclusão. Tarefas independentes podem rodar em paralelo via subagents/team agents.
2. **Implement** — Subaru implementa uma tarefa sequencial ou um grupo paralelo a partir do `HEAD` atual; grupos paralelos são mesclados e verificados como um único resultado.
3. **Evaluate** — `rezero-witches` chama as sete bruxas em paralelo. Elas usam fresh context e não herdam o contexto de Subaru.
4. **Return by Death** — Qualquer `fail` registra memória mínima de falha, executa reset/clean e tenta novamente.
5. **Pass** — Somente `pass`/`warning` passa; warnings vão para Rem memory e então a rota aceita é commitada.
6. **Rem** — Warnings de Rem também precisam ser implementados, verificados, avaliados pelas bruxas e commitados sem fail.

## Skills

- `rezero-init` — setup witch evaluation tools.
- `rezero-orchestrator` — `/rezero` entrypoint.
- `rezero-plan` — large request splitting.
- `rezero-loop` — Subaru single-task loop.
- `rezero-witches` — fresh-context seven-witch review.
- `rezero-rem` — warning memory management.

## Conceitos

### Natsuki Subaru

Subaru is the implementer. Starts from current `HEAD`, implements, verifies, and keeps only the memory needed to avoid repeating a failure.

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

O código morre. A lição sobrevive.

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

Rem é a memória de warnings.

## Licença

Distributed under the [MIT License](../LICENSE).
