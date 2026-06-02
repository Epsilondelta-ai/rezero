[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | **Español** | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop es un flujo de agentes inspirado en **Return by Death** de **Re:Zero − Starting Life in Another World**.

Subaru implementa, siete brujas revisan de forma independiente, la memoria del fallo se conserva y se reintenta desde `HEAD`.

## Instalación

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

`/rezero` checks init state (`.rezero/tools.md` marker + `.rezero/memory/` ignore) and runs init first if missing.

## Flujo de trabajo

1. **Orchestrate** — Si la petición es grande, `rezero-plan` la divide en tareas pequeñas con criterios de finalización. Las tareas independientes pueden ejecutarse en paralelo con subagents/team agents.
2. **Implement** — Subaru implementa una tarea secuencial o un grupo paralelo desde el `HEAD` actual; los grupos paralelos se fusionan y se verifican como un solo resultado.
3. **Evaluate** — `rezero-witches` llama a las siete brujas en paralelo. Usan fresh context y no heredan el contexto de Subaru.
4. **Return by Death** — Cualquier `fail` registra memoria mínima de fallo, ejecuta reset/clean y reintenta.
5. **Pass** — Solo `pass`/`warning` pasa; los warnings van a Rem memory y luego se confirma el commit.
6. **Rem** — Los warnings de Rem también se implementan, verifican, evalúan por brujas y se commitean sin fail.

## Skills

- `rezero-init` — setup witch evaluation tools.
- `rezero` — `/rezero` entrypoint.
- `rezero-plan` — large request splitting.
- `rezero-subaru` — Subaru single-task loop.
- `rezero-witches` — fresh-context seven-witch review.
- `rezero-rem` — warning memory management.

## Idioma y nombres

En idiomas compatibles, Re:ZERO responde en el idioma del usuario. Los nombres de brujas y agentes paralelos usan la forma de ese idioma. Idiomas no compatibles usan inglés.

| Type | Names |
| --- | --- |
| Witches | Echidna, Typhon, Minerva, Daphne, Carmilla, Sekhmet, Satella |
| Parallel implementers | Beatrice, Emilia, Ram, Garfiel, Julius |

## Conceptos

### Natsuki Subaru

Subaru is the implementer. Starts from current `HEAD`, implements, verifies, and keeps only the memory needed to avoid repeating a failure.

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

El código muere. La lección sobrevive.

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

Rem es la memoria de warnings.

## Licencia

Distributed under the [MIT License](../LICENSE).
