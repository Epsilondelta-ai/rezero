[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | **Deutsch**

# Re:ZERO Loop

> Re:ZERO Loop ist ein Agenten-Workflow, inspiriert von **Return by Death** aus **Re:ZERO -Starting Life in Another World-**.

![](./images/rezero.webp)

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

*Installiere danach `rezero` über `/plugins` und starte eine neue Sitzung.*

## Verwendung

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

## Return by Death BGM

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

1. Wir stellen Subaru vor eine Prüfung.
2. Subaru bemüht sich, die Prüfung zu überwinden.
3. Doch wie immer kann er scheitern und Return by Death auslösen.  
   Das ist hier zwar etwas ungewohnt, aber die Sieben Hexen beurteilen Subarus Schicksal.  
   Jede der Sieben Hexen beurteilt Subarus Schicksal anhand eigener Kennzahlen. Welche Kennzahlen sie verwenden, kannst du [hier](#sieben-hexen) nachsehen.
4. Wenn Subarus Bemühungen scheitern und er Return by Death auslöst, wird die Bewertung der Sieben Hexen in `.rezero/memory/subaru-deaths.md` gespeichert. (Diese Datei ist in gitignore enthalten und wird daher nicht zurückgesetzt.)  
   Anschließend werden `git reset --hard HEAD` und `git clean -fd` ausgeführt, um Return by Death durchzuführen.
5. Subaru wiederholt den obigen Prozess, bis er diese Prüfung überwindet. Die Dateien `.rezero/memory/subaru-deaths.md` und `.rezero/memory/rem.md` werden gelöscht.
6. Wenn der Checkpoint von Return by Death nach dem Überwinden der Prüfung aktualisiert wurde, aber es Punkte gibt, die die Hexen als warning bewertet haben, werden sie in `.rezero/memory/rem.md` aufgezeichnet.
7. Subaru bricht erneut zu der oben beschriebenen Reise auf, um Rem zu retten.
8. Wenn Subaru die gestellte Prüfung überwindet und es schafft, Rem zu retten, kann er nach langer Zeit endlich ruhen.

## Konzept

### Return by Death

![Subaru](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

Inspiriert wurde dies von Subarus Return by Death.  
Das Konzept entstand aus der Frage, ob man wirklich ordentlich arbeiten kann, wenn man auf bereits unordentlichem Code zusätzlich unordentlichen Kontext mit sich trägt.

### Sieben Hexen

![Witches' Tea Party](./images/witches-tea-party.webp)

Als Fan des Originals wirkt es etwas ungewohnt, dass die Sieben Hexen Subarus Schicksal beurteilen,  
aber eine Bewertung aus mehreren Blickwinkeln ist eine ziemlich gute Idee, daher wurde dieses Konzept übernommen.

| Hexe | Fokus | Beispiel-Tools |
| --- | --- | --- |
| Echidna | Vollständigkeit, Randfälle, Coverage | selbst gehostetes SonarQube, coverage, Stryker |
| Typhon | Verträge, Spezifikationen, öffentliche Schnittstellen | typecheck, linter, Spectral, Pact |
| Minerva | Schaden für Nutzer, Regressionen, Laufzeitfehler | tests, Playwright, Lighthouse CI, k6 |
| Daphne | Abhängigkeits-/Ressourcenverbrauch | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Täuschung in UI/Dokumentation/Namen/Nachweisen | screenshots, axe, lychee |
| Sekhmet | Wartbarkeit, dead code, Duplikate | selbst gehostetes SonarQube, Knip, jscpd |
| Satella | Integration, Sicherheit, Richtlinien, Konsistenz | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem (Spoiler-Warnung)

![Rem](./images/rem.webp)

Sie ist im Original der wichtigste Grund, warum Subaru seine Reise antritt.  
Er tut es, um Rem zu retten.

Im Original wurde der Checkpoint zwar nach dem erfolgreichen Kampf gegen den Weißen Wal aktualisiert,  
aber Rems Existenz wurde vom Erzbischof der Sünde der Völlerei verschlungen, sodass sie nicht mehr aufwachen konnte.

Davon inspiriert kam mir der Gedanke: Wenn der Checkpoint aktualisiert wurde,  
es aber warnings gibt, warum betrachten wir sie nicht als Rem?

## Lizenz

Dieses Projekt wird unter der [MIT License](../LICENSE) vertrieben.
