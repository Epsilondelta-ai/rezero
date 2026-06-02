[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | **日本語** | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop は **Re:Zero − Starting Life in Another World** の **Return by Death** に着想を得たエージェントワークフローです。

Subaru が実装し、七人の魔女が独立レビューし、失敗の記憶を保持したまま `HEAD` から再試行します。

## 目次

- [インストール](#インストール)
- [使い方](#使い方)
- [ワークフロー](#ワークフロー)
- [スキル](#スキル)
- [コンセプト](#コンセプト)
- [ライセンス](#ライセンス)

## インストール

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

その後 `/plugins` で `rezero` をインストールし、新しいセッションを開始します。

## 使い方

```text
/rezero init
/rezero <task>
```

## ワークフロー

1. **オーケストレーション** — `/rezero` が `rezero-orchestrator` を読み込みます。大きい依頼は `rezero-plan` が done 条件付きの小タスクに分割します。独立タスクは subagent/team agent で並列化できます。
2. **実装** — Subaru は現在の `HEAD` から、単一タスクまたは並列タスクグループを実装します。並列グループはマージ後、結合結果として検証します。
3. **評価** — `rezero-witches` が七人の魔女を並列呼び出しします。魔女は確証バイアスを避けるため Subaru のコンテキストを継承しません。結果は `witch | verdict | reason | evidence` テーブルで表示します。
4. **Return by Death** — ひとつでも `fail` があれば `.rezero/memory/subaru-deaths.md` に最小限の失敗記憶を書き、`git reset --hard HEAD && git clean -fd` 後に再試行します。
5. **通過** — `pass`/`warning` のみなら warning を `.rezero/memory/rem.md` に保存し、accepted route をコミットします。コミット後 death memory を削除します。
6. **Rem** — Rem warning も通常の Re:ZERO attempt として実装、検証、魔女評価、fail なしでコミットします。すべて解決したら `rem.md` を削除します。

## スキル

- `rezero-init` — setup witch evaluation tools.
- `rezero-orchestrator` — `/rezero` のエントリポイント。
- `rezero-plan` — 大きい依頼を小さい ordered tasks に分割。
- `rezero-loop` — Subaru の単一タスク実装ループ。
- `rezero-witches` — fresh-context の七魔女レビューと verdict table。
- `rezero-rem` — warning memory の保存、解決、削除。

## コンセプト

### ナツキ・スバル

ナツキ・スバルは実装者です。現在の `HEAD` から開始し、実装と検証を行い、失敗時は同じ失敗を避けるための記憶だけを残します。

### Return by Death

![Natsuki Subaru](./images/subaru.webp)

```bash
git reset --hard HEAD
git clean -fd
```

コードは死に、教訓は残ります。

### Seven Witches

![Witches' Tea Party](./images/witches-tea-party.webp)

| Witch | Focus | Example tools |
| --- | --- | --- |
| エキドナ | 完全性、エッジケース、カバレッジ | SonarQube, coverage, Stryker |
| テュフォン | 契約、仕様、公開インターフェース | typecheck, linter, Spectral, Pact |
| ミネルヴァ | ユーザー被害、回帰、実行時失敗 | tests, Playwright, Lighthouse CI, k6 |
| ダフネ | 依存関係とリソース消費 | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| カーミラ | UI/文書/名前/証明の欺瞞 | screenshots, axe, lychee |
| セクメト | 保守性、dead code、重複 | SonarQube, Knip, jscpd |
| サテラ | 統合、セキュリティ、ポリシー、一貫性 | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### レム

![Rem](./images/rem.webp)

レムは warning memory です。通過した warning は `.rezero/memory/rem.md` に残り、修正、再評価、コミットされるまで維持されます。

## ライセンス

このプロジェクトは [MIT License](../LICENSE) で配布されます。
