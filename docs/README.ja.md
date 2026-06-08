[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | **日本語** | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop は、**Re:ゼロから始める異世界生活** の **死に戻り** に着想を得たエージェントワークフローです。

![](./images/rezero.webp)

## インストール

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

*その後、`/plugins` で `rezero` をインストールし、新しいセッションを開始します。*

## 使い方

Pi、Claude Code、Codex で：

```text
/rezero:run <task>
```

Codex:

```text
$rezero:run <task>
```

`/rezero:run` は init 状態（`.rezero/tools.md` のマーカー + `.rezero/memory/` の ignore）を確認し、存在しなければ先に init を自動実行します。

## 死に戻り BGM

Re:ZERO Loop が死に戻りを実行すると、プラグインはデフォルトで `assets/bgm.mp3` を再生します。

現在のプロジェクトで無効にするには、`/rezero:run bgm false` または `/rezero:run bgm off` を使います：

```text
/rezero:run bgm false
/rezero:run bgm off
$rezero:run bgm false
$rezero:run bgm off
```

再び有効にするには、`/rezero:run bgm true` または `/rezero:run bgm on` を使います：

```text
/rezero:run bgm true
/rezero:run bgm on
$rezero:run bgm true
$rezero:run bgm on
```

これらのコマンドは `.rezero/memory/config.json` を書き込みます：

```json
{
  "bgm": false
}
```

1 回の実行、またはシェルプロファイルで無効にすることもできます：

```bash
export REZERO_BGM_DISABLE=1
```

## ワークフロー

1. 私たちはスバルに試練を与えます。
2. スバルは試練を乗り越えるために努力します。
3. しかし、いつものように失敗して死に戻りすることがあります。  
   ここは少し不自然ではありますが、七人の魔女がスバルの運命を判断します。  
   七人の魔女はそれぞれの指標でスバルの運命を判断します。どのような指標で判断するかは[こちら](#七人の魔女)で確認できます。
4. スバルの努力が失敗に終わり死に戻りすることになると、七人の魔女の評価を `.rezero/memory/subaru-deaths.md` に記憶します。（このファイルは gitignore に含まれているためリセットされません。）  
   その後、`git reset --hard HEAD` と `git clean -fd` を実行して死に戻りします。
5. スバルはこの試練を乗り越えるまで、上記の過程を繰り返します。`.rezero/memory/subaru-deaths.md` と `.rezero/memory/rem.md` ファイルを削除します。
6. 試練を乗り越えて死に戻りのチェックポイントが更新されたものの、魔女たちが warning と評価した項目がある場合は `.rezero/memory/rem.md` に記録します。
7. スバルはレムを救うため、再び上記の旅に出ます。
8. 与えられた試練を乗り越え、レムを救うことに成功したなら、スバルは久しぶりに休むことになります。

## コンセプト

### 死に戻り

![スバル](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

スバルの死に戻りから着想を得ました。  
すでに汚いコードの上で、汚いコンテキストを抱えたまま、本当にまともにできるのかという疑問から、この概念を借用することになりました。

### 七人の魔女

![Witches' Tea Party](./images/witches-tea-party.webp)

原作のファンとして、七人の魔女がスバルの運命を判断するというのは少し不自然にも感じますが、  
複数の観点から評価を下すというのはかなり良いアイデアなので、この概念を借用しました。

| 魔女 | 注目点 | 例のツール |
| --- | --- | --- |
| エキドナ | 完全性、エッジケース、カバレッジ | セルフホスト SonarQube, coverage, Stryker |
| テュフォン | 契約、仕様、公開インターフェース | typecheck, linter, Spectral, Pact |
| ミネルヴァ | ユーザー被害、回帰、ランタイム失敗 | tests, Playwright, Lighthouse CI, k6 |
| ダフネ | 依存関係/リソース消費 | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| カーミラ | UI/ドキュメント/名前/証明の欺瞞 | screenshots, axe, lychee |
| セクメト | 保守性、dead code、重複 | セルフホスト SonarQube, Knip, jscpd |
| サテラ | 統合、セキュリティ、ポリシー、一貫性 | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### レム（ネタバレ注意）

![Rem](./images/rem.webp)

原作でスバルが旅に出る最も大きな理由です。  
レムを救うためです。

原作でも白鯨討伐戦に成功してチェックポイントは更新されましたが、  
レムは暴食の大罪司教に存在を喰われ、目覚められなくなります。

この点に着想を得て、チェックポイントは更新されたけれど、  
warning があるならそれをレムと見なしてはどうか、と考えました。

## ライセンス

このプロジェクトは [MIT License](../LICENSE) の下で配布されています。
