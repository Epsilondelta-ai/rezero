[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | **Deutsch**

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop ist ein Agenten-Workflow, inspiriert von **Return by Death** aus **Re:Zero − Starting Life in Another World**.

Subaru implementiert, sieben Hexen prüfen unabhängig, Fehlererinnerung bleibt erhalten und der Versuch startet erneut von `HEAD`.

## Installation

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

## Verwendung

```text
/rezero init
/rezero <task>
```

## Workflow

1. **Orchestrate** — Wenn die Anfrage groß ist, zerlegt `rezero-plan` sie in kleine Aufgaben mit Done-Kriterien. Unabhängige Aufgaben können per subagents/team agents parallel laufen.
2. **Implement** — Subaru implementiert eine sequentielle Aufgabe oder eine parallele Gruppe ab aktuellem `HEAD`; parallele Gruppen werden zuerst gemergt und dann als ein Ergebnis geprüft.
3. **Evaluate** — `rezero-witches` ruft sieben Hexen parallel auf. Sie nutzen fresh context und übernehmen nicht Subarus Kontext.
4. **Return by Death** — Jedes `fail` schreibt minimale Fehlererinnerung, führt reset/clean aus und versucht es erneut.
5. **Pass** — Nur `pass`/`warning` besteht; warnings gehen in Rem memory und die akzeptierte Route wird committet.
6. **Rem** — Rem warnings werden ebenfalls implementiert, verifiziert, von Hexen bewertet und nur ohne fail committet.

## Skills

- `rezero-init` — setup witch evaluation tools.
- `rezero-orchestrator` — `/rezero` entrypoint.
- `rezero-plan` — large request splitting.
- `rezero-loop` — Subaru single-task loop.
- `rezero-witches` — fresh-context seven-witch review.
- `rezero-rem` — warning memory management.

## Sprache und Namen

In unterstützten Sprachen antwortet Re:ZERO in der Sprache des Nutzers. Hexen- und Parallel-Agentennamen verwenden die jeweilige Sprachform. Nicht unterstützte Sprachen fallen auf Englisch zurück.

| Type | Names |
| --- | --- |
| Witches | Echidna, Typhon, Minerva, Daphne, Carmilla, Sekhmet, Satella |
| Parallel implementers | Beatrice, Emilia, Ram, Garfiel, Julius |

## Konzepte

### Natsuki Subaru

Subaru is the implementer. Starts from current `HEAD`, implements, verifies, and keeps only the memory needed to avoid repeating a failure.

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

Der Code stirbt. Die Lektion bleibt.

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

Rem ist warning memory.

## Lizenz

Distributed under the [MIT License](../LICENSE).
