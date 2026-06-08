[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | **Русский** | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop — это агентный workflow, вдохновлённый **Возвращением смертью** из **Re:ZERO -Starting Life in Another World-**.

![](./images/rezero.webp)

## Установка

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

*После этого установите `rezero` через `/plugins` и начните новую сессию.*

## Использование

In Pi:

```text
/rezero <task>
```

In Claude Code:

```text
/rezero:run <task>
```

In Codex:

```text
$rezero:run <task>
```

`/rezero`, `/rezero:run`, and `$rezero:run` check the init state (`.rezero/tools.md` marker + `.rezero/memory/` ignore). If it is missing, init runs first automatically.

## BGM Возвращения смертью

When Re:ZERO Loop performs Return by Death, the plugin plays `assets/bgm.mp3` by default.

Use these commands to disable BGM for the current project:

```text
/rezero bgm false
/rezero bgm off
/rezero:run bgm false
/rezero:run bgm off
$rezero:run bgm false
$rezero:run bgm off
```

Use these commands to enable it again:

```text
/rezero bgm true
/rezero bgm on
/rezero:run bgm true
/rezero:run bgm on
$rezero:run bgm true
$rezero:run bgm on
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

1. Мы даём Субару испытание.
2. Субару старается преодолеть это испытание.
3. Но, как всегда, он может потерпеть неудачу и вернуться смертью.  
   Здесь это немного неловко, но Семь Ведьм судят судьбу Субару.  
   Каждая из Семи Ведьм судит судьбу Субару по своим показателям. Узнать, по каким показателям они судят, можно [здесь](#семь-ведьм).
4. Если усилия Субару заканчиваются провалом и он возвращается смертью, оценка Семи Ведьм запоминается в `.rezero/memory/subaru-deaths.md`. (Этот файл включён в gitignore, поэтому он не сбрасывается.)  
   После этого выполняются `git reset --hard HEAD` и `git clean -fd`, чтобы выполнить Возвращение смертью.
5. Субару повторяет описанный выше процесс, пока не преодолеет это испытание. Файлы `.rezero/memory/subaru-deaths.md` и `.rezero/memory/rem.md` удаляются.
6. Если после преодоления испытания checkpoint Возвращения смертью был обновлён, но есть пункты, которые ведьмы оценили как warning, они записываются в `.rezero/memory/rem.md`.
7. Субару снова отправляется в описанное выше путешествие, чтобы спасти Рем.
8. Если Субару преодолеет данное испытание и успешно спасёт Рем, он наконец сможет отдохнуть после долгого времени.

## Концепция

### Возвращение смертью

![Субару](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

Идея вдохновлена Возвращением смертью Субару.  
Эта концепция была заимствована из сомнения: можно ли действительно сделать всё как следует, имея грязный контекст поверх уже грязного кода?

### Семь Ведьм

![Witches' Tea Party](./images/witches-tea-party.webp)

Как фанату оригинала, мне немного неловко от того, что Семь Ведьм судят судьбу Субару,  
но оценка с нескольких точек зрения — довольно хорошая идея, поэтому эта концепция была заимствована.

| Ведьма | Фокус | Примеры инструментов |
| --- | --- | --- |
| Эхидна | Полнота, граничные случаи, покрытие | самостоятельно размещённый SonarQube, coverage, Stryker |
| Тифон | Контракты, спецификации, публичные интерфейсы | typecheck, linter, Spectral, Pact |
| Минерва | Вред пользователю, регрессии, сбои во время выполнения | tests, Playwright, Lighthouse CI, k6 |
| Дафна | Потребление зависимостей/ресурсов | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Кармилла | Обман в UI/документации/именах/доказательствах | screenshots, axe, lychee |
| Сехмет | Поддерживаемость, dead code, дублирование | самостоятельно размещённый SonarQube, Knip, jscpd |
| Сателла | Интеграция, безопасность, политики, согласованность | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Рем (осторожно, спойлеры)

![Rem](./images/rem.webp)

В оригинале она является главной причиной, по которой Субару отправляется в путь.  
Он делает это, чтобы спасти Рем.

В оригинале, даже после успешной битвы с Белым Китом и обновления checkpoint,  
существование Рем было поглощено Архиепископом греха Чревоугодия, и она больше не смогла проснуться.

Вдохновившись этим моментом, я подумал: даже если checkpoint обновлён,  
если есть warnings, почему бы не считать их Рем?

## Лицензия

Этот проект распространяется по [MIT License](../LICENSE).
