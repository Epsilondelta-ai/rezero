[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | **Français** | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop est un workflow d’agents inspiré du **Return by Death** de **Re:Zero − Starting Life in Another World**.

Subaru implémente, sept sorcières relisent indépendamment, la mémoire d’échec est conservée et la tentative repart de `HEAD`.

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

## Utilisation

```text
/rezero init
/rezero <task>
```

`/rezero` checks init state (`.rezero/tools.md` marker + `.rezero/memory/` ignore) and runs init first if missing.

## Flux de travail

1. **Orchestrate** — Si la demande est grande, `rezero-plan` la découpe en petites tâches avec critères de fin. Les tâches indépendantes peuvent tourner en parallèle via subagents/team agents.
2. **Implement** — Subaru implémente une tâche séquentielle ou un groupe parallèle depuis le `HEAD` courant ; les groupes parallèles sont fusionnés puis vérifiés comme un seul résultat.
3. **Evaluate** — `rezero-witches` appelle les sept sorcières en parallèle. Elles utilisent un fresh context et n’héritent pas du contexte de Subaru.
4. **Return by Death** — Tout `fail` enregistre une mémoire minimale d’échec, exécute reset/clean, puis réessaie.
5. **Pass** — Seuls `pass`/`warning` passent ; les warnings vont dans Rem memory puis la route acceptée est commitée.
6. **Rem** — Les warnings de Rem sont aussi implémentés, vérifiés, évalués par les sorcières et commités sans fail.

## Compétences

- `rezero-init` — setup witch evaluation tools.
- `rezero-orchestrator` — `/rezero` entrypoint.
- `rezero-plan` — large request splitting.
- `rezero-loop` — Subaru single-task loop.
- `rezero-witches` — fresh-context seven-witch review.
- `rezero-rem` — warning memory management.

## Langue et noms

Dans les langues prises en charge, Re:ZERO répond dans la langue de l’utilisateur. Les noms des sorcières et agents parallèles suivent cette langue. Les langues non prises en charge utilisent l’anglais.

| Type | Names |
| --- | --- |
| Witches | Echidna, Typhon, Minerva, Daphné, Carmilla, Sekhmet, Satella |
| Parallel implementers | Béatrice, Émilia, Ram, Garfiel, Julius |

## Concepts

### Subaru Natsuki

Subaru is the implementer. Starts from current `HEAD`, implements, verifies, and keeps only the memory needed to avoid repeating a failure.

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

Le code meurt. La leçon survit.

### Seven Witches

![Witches' Tea Party](./images/witches-tea-party.webp)

| Witch | Focus | Example tools |
| --- | --- | --- |
| Echidna | Completeness, edge cases, coverage | SonarQube, coverage, Stryker |
| Typhon | Contracts, specs, public interfaces | typecheck, linter, Spectral, Pact |
| Minerva | User harm, regressions, runtime failures | tests, Playwright, Lighthouse CI, k6 |
| Daphné | Dependency/resource appetite | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Deceptive UI/docs/names/proof | screenshots, axe, lychee |
| Sekhmet | Maintainability, dead code, duplication | SonarQube, Knip, jscpd |
| Satella | Integration, security, policy, consistency | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem

![Rem](./images/rem.webp)

Rem est la mémoire des warnings.

## Licence

Distributed under the [MIT License](../LICENSE).
