**English** | [한국어](./docs/README.ko.md) | [简体中文](./docs/README.zh-CN.md) | [日本語](./docs/README.ja.md) | [Español](./docs/README.es.md) | [Português (BR)](./docs/README.pt-BR.md) | [Français](./docs/README.fr.md) | [Русский](./docs/README.ru.md) | [Deutsch](./docs/README.de.md)

# Re:ZERO Loop

![](./docs/images/rezero.webp)

> Re:ZERO Loop is a project inspired by **Return by Death** from **Re:Zero − Starting Life in Another World**.

Techniques like Ralph Loop have emerged to prevent AI performance degradation caused by context pollution from accumulated context.  
However, even if the context is kept clean, if the accumulated code becomes polluted, performance degradation due to the codebase is unavoidable.

Re:ZERO Loop was born from the idea of introducing Return by Death to AI to overcome this problem.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Option 1: Copy directly to your project](#option-1-copy-directly-to-your-project)
  - [Option 2: Install skills globally](#option-2-install-skills-globally)
  - [Option 3: Install as a Pi package](#option-3-install-as-a-pi-package)
  - [Option 4: Use as a Claude Code plugin](#option-4-use-as-a-claude-code-plugin)
- [Workflow](#workflow)
  - [1. Create a task definition](#1-create-a-task-definition)
  - [2. Run the Re:ZERO Loop](#2-run-the-rezero-loop)
- [Concepts](#concepts)
  - [Natsuki Subaru](#natsuki-subaru)
  - [Return by Death](#return-by-death)
  - [Witches' Tea Party](#witches-tea-party)
  - [Rem](#rem)
- [License](#license)

## Prerequisites

- **AI coding tool** (one of the following):
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
  - [OpenAI Codex](https://openai.com/index/codex/)
- **jq** installed (`brew install jq` on macOS)
- A **git repository** for your project

## Installation

### Option 1: Copy directly to your project

```bash
mkdir -p scripts/rezero
cp /path/to/rezero/rezero.sh scripts/rezero/
cp -r /path/to/rezero/prompts scripts/rezero/prompts
chmod +x scripts/rezero/rezero.sh
```

### Option 2: Install skills globally

```bash
cp -r skills/task ~/.claude/skills/
cp -r skills/rezero ~/.claude/skills/
cp -r skills/witches-tea-party ~/.claude/skills/
cp -r skills/rem ~/.claude/skills/
```

### Option 3: Install as a Pi package

```bash
pi install git:github.com/epsilondelta-ai/rezero
```

Local development:

```bash
pi install /path/to/rezero
```

After installation, `/skill:rezero-loop` becomes available.

### Option 4: Use as a Claude Code plugin

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero@rezero-marketplace
```

After installation, `/skill:rezero-loop` becomes available.

## Workflow

### 1. Create a task definition

Use the task skill to define a user story:

> "Load the task skill and create a task for [feature description]"

Output: `task.json` (a user story with priorities and acceptance criteria)

### 2. Run the Re:ZERO Loop

```bash
./rezero.sh [max_iterations]                        # Claude (default)
./rezero.sh --tool codex [max_iterations]           # OpenAI Codex
./rezero.sh --max-deaths 5 [max_iterations]         # Set max Return by Death per story
```

Default iterations: 10, default max deaths: 3

**Execution flow (4 phases per iteration):**

1. Creates a feature branch from `task.json`
2. **Phase 1 — Implementation (Subaru)**: Selects the highest priority incomplete story and implements it
3. **Phase 2 — Witches' Tea Party (6 parallel sessions)**: Six witches evaluate the code simultaneously, each in their own independent session
4. **Phase 3 — Final Judgment (Satella)**: Aggregates the six verdicts, commits on pass or triggers Return by Death on fail
5. **Phase 4 — Technical Debt (Rem)**: Records evaluation warnings in `rem.md`, reviews existing debt, checks for loop completion
6. Repeats until all stories are complete or max iterations reached

Each iteration runs up to **9 sessions**: 1 implementation + 6 parallel evaluators + 1 judgment + 1 debt management. The six witches run in parallel for fast, unbiased evaluation — each evaluator is completely independent from the implementer and from each other.

## Concepts

### Natsuki Subaru

Natsuki Subaru is the protagonist of Re:Zero.

- In this project, the agent performing the work is named **Natsuki Subaru**.
- Rather than simply executing tasks, it accumulates knowledge through multiple Returns by Death.
- It devises an optimal plan each time to achieve its goal.

### Return by Death

![Natsuki Subaru](./docs/images/subaru.webp)

When an anomaly is detected during work, or when the results are unsatisfactory even after completion, Natsuki Subaru uses Return by Death to revert to a checkpoint.

- If an anomaly is detected during work, it stops and uses Return by Death to revert to the checkpoint.
- If the Witches' Tea Party determines that the success criteria have not been met, it forces a Return by Death.
- The key significance of Return by Death is that it returns to the checkpoint while retaining memories of why it failed.

### Witches' Tea Party

![Witches' Tea Party](./docs/images/witches-tea-party.webp)

Fans familiar with the original setting might find it surprising that the **Witches' Tea Party** serves as the evaluator.  
However, the fact that the six witches each have different personalities, combined with the speculation that Satella may determine Subaru's checkpoints, made this a fitting role for the evaluation system.

- After work is completed, the "Witches' Tea Party" convenes.
- The six witches evaluate the work from their respective perspectives.
- Satella aggregates the six witches' evaluations to determine whether to update the checkpoint or trigger Return by Death.

| Witch              | Evaluation Criteria                                                                                                                                                                                                |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Echidna (Greed)    | Has this implementation explored all possibilities? Are all edge cases handled? Is the knowledge thorough? Practically: checks test coverage, API completeness, documentation, and boundary condition handling.     |
| Minerva (Wrath)    | Is this bug truly fixed, or was the problem just redistributed? Does the patch create new failure modes in unrelated features? Runs regression tests and verifies the fix doesn't break unrelated functionality.   |
| Sekhmet (Sloth)    | Could the same result be achieved with less effort? Is there unnecessary complexity? Checks algorithmic efficiency, redundant computations, and over-engineering.                                                   |
| Typhon (Pride)     | Does the code know its own sins? Are there intentionally included anti-patterns? Does it violate its own principles? Detects code smells, linting violations, and acknowledged but unfixed technical debt.          |
| Daphne (Gluttony)  | How hungry is this code? Is the memory/CPU/token consumption justified? Checks memory usage, API call counts, bundle size, and token consumption.                                                                  |
| Carmilla (Lust)    | Does this code fulfill what the user truly wants? Is the UX appealing, or are dangerous flaws hidden behind charm? Evaluates API ergonomics, error messages, and alignment with the user's stated intent.          |
| Satella (Envy)     | The final aggregator. Determines what constitutes an "acceptable result," aggregates the six witches' evaluations using weighted scores, and renders the verdict of survival or death: checkpoint pass or Return by Death trigger. |

### Rem

> **!!! SPOILER ALERT !!!**

![Rem](./docs/images/rem.webp)

After the White Whale subjugation, Rem had her name and memories consumed by the Archbishop of Gluttony, falling into suspended animation.  
The Return by Death checkpoint became fixed after Rem fell into this state, making it impossible to go back further.  
While planning the Re:ZERO Loop, the realization that Rem's existence would be crucial to this project — that technical debt could remain even after passing the Witches' Tea Party — led to incorporating Rem into the project.

- Even after passing the Witches' Tea Party, if technical debt or items requiring future fixes remain, they persist as the checkpoint updates.
- Rem identifies and separately records technical debt and items needing fixes.
- If such items exist, Subaru prioritizes saving Rem before proceeding to the next task.

## License

This project is distributed under the [MIT License](./LICENSE).
