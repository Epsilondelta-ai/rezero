**English** | [한국어](./docs/README.ko.md) | [简体中文](./docs/README.zh-CN.md) | [日本語](./docs/README.ja.md) | [Español](./docs/README.es.md) | [Português (BR)](./docs/README.pt-BR.md) | [Français](./docs/README.fr.md) | [Русский](./docs/README.ru.md) | [Deutsch](./docs/README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop is an agent workflow inspired by **Return by Death** from **Re:ZERO -Starting Life in Another World-**.

![](./docs/images/rezero.webp)

## Installation

### Pi

```bash
pi install npm:rezero
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

*After that, install `rezero` from `/plugins` and start a new session.*

## Usage

In Pi, Claude Code, and Codex:

```text
/rezero <task>
```

`/rezero` checks the init state (`.rezero/tools.md` marker + `.rezero/memory/` ignore). If it is missing, it automatically runs init first.

## Return by Death BGM

When Re:ZERO Loop performs Return by Death, the plugin plays `assets/bgm.mp3` by default.

Use `/rezero bgm false` or `/rezero bgm off` to disable it for the current project:

```text
/rezero bgm false
/rezero bgm off
```

Use `/rezero bgm true` or `/rezero bgm on` to enable it again:

```text
/rezero bgm true
/rezero bgm on
```

These commands write `.rezero/memory/config.json`:

```json
{
  "bgm": false
}
```

You can also disable BGM for one run or for your shell profile:

```bash
export REZERO_BGM_DISABLE=1
```

## Workflow

1. We give Subaru a trial.
2. Subaru makes an effort to overcome the trial.
3. But, as always, he may fail and Return by Death.  
   This is a little awkward, but at this point the Seven Witches judge Subaru's fate.  
   Each of the Seven Witches judges Subaru's fate using her own metrics. You can check [here](#seven-witches) what metrics they use.
4. If Subaru's effort fails and he Returns by Death, the Seven Witches' evaluation is remembered in `.rezero/memory/subaru-deaths.md`. (That file is included in gitignore, so it is not reset.)  
   After that, `git reset --hard HEAD` and `git clean -fd` are run to perform Return by Death.
5. Subaru repeats the process above until he overcomes the trial. The `.rezero/memory/subaru-deaths.md` and `.rezero/memory/rem.md` files are deleted.
6. If the checkpoint is updated after overcoming the trial, but there are items that the witches evaluated as warnings, they are recorded in `.rezero/memory/rem.md`.
7. Subaru sets out on the journey above again to save Rem.
8. If Subaru overcomes the given trial and succeeds in saving Rem, he finally gets to rest after a long time.

## Concept

### Return by Death

![Subaru](./docs/images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

This was inspired by Subaru's Return by Death.  
The idea was borrowed from the question of whether one can really do things properly while holding messy context on top of already messy code.

### Seven Witches

![Witches' Tea Party](./docs/images/witches-tea-party.webp)

As a fan of the original work, it does feel a little awkward that the Seven Witches judge Subaru's fate,  
but evaluating from multiple perspectives is a pretty good idea, so the concept was borrowed.

| Witch | Focus | Example tools |
| --- | --- | --- |
| Echidna | Completeness, edge cases, coverage | SonarQube, coverage, Stryker |
| Typhon | Contracts, specifications, public interfaces | typecheck, linter, Spectral, Pact |
| Minerva | User harm, regressions, runtime failures | tests, Playwright, Lighthouse CI, k6 |
| Daphne | Dependency/resource consumption | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Deception in UI/docs/names/proofs | screenshots, axe, lychee |
| Sekhmet | Maintainability, dead code, duplication | SonarQube, Knip, jscpd |
| Satella | Integration, security, policy, consistency | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem (Spoiler Warning)

![Rem](./docs/images/rem.webp)

She is the main reason Subaru sets out on his journey in the original work.  
He does it to save Rem.

In the original work, even after the White Whale subjugation succeeded and the checkpoint was updated,  
Rem had her existence eaten by the Sin Archbishop of Gluttony and could no longer wake up.

Inspired by that point, I thought: even if the checkpoint is updated,  
if there are warnings, what if we see them as Rem?

## License

This project is distributed under the [MIT License](./LICENSE).
