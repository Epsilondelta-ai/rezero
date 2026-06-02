[English](../README.md) | [한국어](./README.ko.md) | **简体中文** | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop 是受 **Re:Zero − Starting Life in Another World** 的 **死亡回归** 启发的智能体工作流。

Subaru 负责实现，七位魔女独立评审，失败记忆会被保留，并从 `HEAD` 重试。

## 安装

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

## 用法

```text
/rezero init
/rezero <task>
```

`/rezero` checks init state (`.rezero/tools.md` marker + `.rezero/memory/` ignore) and runs init first if missing.

## 工作流程

1. **Orchestrate** — 如果任务很大，`rezero-plan` 会拆成带完成标准的小任务。独立任务可以用 subagent/team agent 并行。
2. **Implement** — Subaru 从当前 `HEAD` 实现单个任务或并行任务组；并行组先合并，再作为一个结果验证。
3. **Evaluate** — `rezero-witches` 并行调用七位魔女。魔女使用 fresh context，不继承 Subaru 的上下文。
4. **Return by Death** — 任何 `fail` 都会记录最小失败记忆，然后执行 reset/clean 并重试。
5. **Pass** — 只有 `pass`/`warning` 时通过；warning 写入 Rem memory，然后提交。
6. **Rem** — Rem warning 也必须实现、验证、经魔女评审且无 fail 后提交。

## 技能

- `rezero-init` — setup witch evaluation tools.
- `rezero-orchestrator` — `/rezero` entrypoint.
- `rezero-plan` — large request splitting.
- `rezero-loop` — Subaru single-task loop.
- `rezero-witches` — fresh-context seven-witch review.
- `rezero-rem` — warning memory management.

## 语言与名称

支持的语言会使用用户语言回答；魔女 verdict 和并行实现 agent 名称也使用对应语言。未支持语言回退到英文。

| Type | Names |
| --- | --- |
| Witches | 艾姬多娜, 堤丰, 弥涅耳瓦, 达芙妮, 卡密拉, 塞赫麦特, 莎缇拉 |
| Parallel implementers | 碧翠丝, 艾米莉娅, 拉姆, 加菲尔, 尤里乌斯 |

## 概念

### 菜月昴

菜月昴是实现者。他从当前 `HEAD` 开始，实现并验证任务，只保留避免重复失败所需的记忆。

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

代码会死，教训会留下。

### Seven Witches

![Witches' Tea Party](./images/witches-tea-party.webp)

| Witch | Focus | Example tools |
| --- | --- | --- |
| 艾姬多娜 | Completeness, edge cases, coverage | SonarQube, coverage, Stryker |
| 堤丰 | Contracts, specs, public interfaces | typecheck, linter, Spectral, Pact |
| 弥涅耳瓦 | User harm, regressions, runtime failures | tests, Playwright, Lighthouse CI, k6 |
| 达芙妮 | Dependency/resource appetite | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| 卡密拉 | Deceptive UI/docs/names/proof | screenshots, axe, lychee |
| 塞赫麦特 | Maintainability, dead code, duplication | SonarQube, Knip, jscpd |
| 莎缇拉 | Integration, security, policy, consistency | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### 雷姆

![Rem](./images/rem.webp)

Rem 是 warning memory。

## 许可证

Distributed under the [MIT License](../LICENSE).
