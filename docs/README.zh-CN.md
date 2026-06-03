[English](../README.md) | [한국어](./README.ko.md) | **简体中文** | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop 是一个受 **Re:从零开始的异世界生活** 中 **死亡回归** 启发的代理工作流。

![](./images/rezero.webp)

## 安装

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

*之后，在 `/plugins` 中安装 `rezero`，并开始一个新会话。*

## 用法

在 Pi、Claude Code、Codex 中：

```text
/rezero <task>
```

`/rezero` 会检查 init 状态（`.rezero/tools.md` 标记 + `.rezero/memory/` ignore）。如果不存在，会先自动执行 init。

## 死亡回归 BGM

当 Re:ZERO Loop 执行死亡回归时，插件默认播放 `assets/bgm.mp3`。

若要在当前项目中关闭，请使用 `/rezero bgm false` 或 `/rezero bgm off`：

```text
/rezero bgm false
/rezero bgm off
```

若要重新开启，请使用 `/rezero bgm true` 或 `/rezero bgm on`：

```text
/rezero bgm true
/rezero bgm on
```

这些命令会写入 `.rezero/memory/config.json`：

```json
{
  "bgm": false
}
```

也可以在一次运行或 shell 配置中关闭：

```bash
export REZERO_BGM_DISABLE=1
```

## 工作流

1. 我们给昴降下一场试炼。
2. 昴为了克服试炼而努力。
3. 然而，一如既往，他可能会失败并进行死亡回归。  
   这里虽然稍微有些别扭，但七位魔女会判断昴的命运。  
   七位魔女会用各自的指标来判断昴的命运。可以在[这里](#七位魔女)查看她们用什么指标进行判断。
4. 如果昴的努力以失败告终并死亡回归，七位魔女的评价会被记忆到 `.rezero/memory/subaru-deaths.md`。（该文件包含在 gitignore 中，因此不会被重置。）  
   之后执行 `git reset --hard HEAD` 和 `git clean -fd`，完成死亡回归。
5. 昴会重复上述过程，直到克服这场试炼为止。删除 `.rezero/memory/subaru-deaths.md` 和 `.rezero/memory/rem.md` 文件。
6. 虽然克服试炼后死亡回归的检查点已被更新，但如果有被魔女们评为 warning 的项目，就会记录到 `.rezero/memory/rem.md` 中。
7. 昴为了拯救蕾姆，再次踏上上述旅程。
8. 如果他成功克服被降下的试炼，并成功拯救蕾姆，昴就能久违地休息了。

## 概念

### 死亡回归

![昴](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

灵感来自昴的死亡回归。  
这个概念源于一个疑问：在已经混乱的代码之上，再带着混乱的上下文，真的还能好好完成任务吗？

### 七位魔女

![Witches' Tea Party](./images/witches-tea-party.webp)

作为原作粉丝，七位魔女判断昴的命运这件事确实会让人觉得稍微有些别扭，  
但从多个视角进行评价是个相当不错的想法，因此借用了这个概念。

| 魔女 | 关注点 | 示例工具 |
| --- | --- | --- |
| 艾姬多娜 | 完整性、边界情况、覆盖率 | SonarQube, coverage, Stryker |
| 提丰 | 契约、规范、公开接口 | typecheck, linter, Spectral, Pact |
| 弥涅耳瓦 | 用户伤害、回归、运行时失败 | tests, Playwright, Lighthouse CI, k6 |
| 达芙妮 | 依赖/资源消耗 | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| 卡蜜拉 | UI/文档/命名/证明中的欺骗性 | screenshots, axe, lychee |
| 塞赫麦特 | 可维护性、死代码、重复 | SonarQube, Knip, jscpd |
| 嫉妒魔女莎缇拉 | 集成、安全、策略、一致性 | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### 蕾姆（剧透注意）

![Rem](./images/rem.webp)

她是原作中昴踏上旅程的最主要理由。  
是为了拯救蕾姆。

在原作中，即使白鲸讨伐战成功、检查点得到更新，  
蕾姆仍被暴食大罪司教吞噬了存在，无法醒来。

受到这一点启发，我想到：虽然检查点更新了，  
但如果还有 warning，把它看作蕾姆会怎么样呢？

## 许可证

本项目根据 [MIT License](../LICENSE) 发布。
