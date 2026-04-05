[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | **Deutsch**

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop ist ein Projekt, das von der **Rückkehr durch den Tod** aus **Re:Zero − Starting Life in Another World** inspiriert wurde.

Um die Leistungsverschlechterung der KI durch Kontextverschmutzung zu verhindern, sind Techniken wie Ralph Loop entstanden.  
Selbst wenn der Kontext sauber gehalten wird, ist eine Leistungsverschlechterung durch die Codebasis unvermeidlich, wenn sich der angesammelte Code verschmutzt.

Re:ZERO Loop entstand aus der Idee, die Rückkehr durch den Tod in die KI einzuführen, um dieses Problem zu überwinden.

## Inhaltsverzeichnis

- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
  - [Option 1: Direkt ins Projekt kopieren](#option-1-direkt-ins-projekt-kopieren)
  - [Option 2: Skills global installieren](#option-2-skills-global-installieren)
  - [Option 3: Als Claude Code Plugin verwenden](#option-3-als-claude-code-plugin-verwenden)
- [Arbeitsablauf](#arbeitsablauf)
  - [1. Aufgabendefinition erstellen](#1-aufgabendefinition-erstellen)
  - [2. Re:ZERO Loop ausführen](#2-rezero-loop-ausführen)
- [Konzepte](#konzepte)
  - [Natsuki Subaru](#natsuki-subaru)
  - [Rückkehr durch den Tod](#rückkehr-durch-den-tod)
  - [Die Teeparty der Hexen](#die-teeparty-der-hexen)
  - [Rem](#rem)
- [Lizenz](#lizenz)

## Voraussetzungen

- **KI-Codierungswerkzeug** (eines der folgenden):
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
  - [Amp CLI](https://ampcode.com)
  - [OpenAI Codex](https://openai.com/index/codex/)
- **jq** installiert (`brew install jq` auf macOS)
- Ein **Git-Repository** für Ihr Projekt

## Installation

### Option 1: Direkt ins Projekt kopieren

```bash
mkdir -p scripts/rezero
cp /path/to/rezero/rezero.sh scripts/rezero/
cp /path/to/rezero/prompt.md scripts/rezero/prompt.md
chmod +x scripts/rezero/rezero.sh
```

### Option 2: Skills global installieren

**Amp-Benutzer:**
```bash
cp -r skills/task ~/.config/amp/skills/
cp -r skills/rezero ~/.config/amp/skills/
cp -r skills/witches-tea-party ~/.config/amp/skills/
cp -r skills/rem ~/.config/amp/skills/
```

**Claude Code-Benutzer:**
```bash
cp -r skills/task ~/.claude/skills/
cp -r skills/rezero ~/.claude/skills/
cp -r skills/witches-tea-party ~/.claude/skills/
cp -r skills/rem ~/.claude/skills/
```

### Option 3: Als Claude Code Plugin verwenden

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero-skills@rezero-marketplace
```

Nach der Installation sind die Skills `/task` und `/rezero` verfügbar.

## Arbeitsablauf

### 1. Aufgabendefinition erstellen

Verwenden Sie den Task-Skill, um eine User Story zu definieren:

> „Laden Sie den Task-Skill und erstellen Sie eine Aufgabe für [Funktionsbeschreibung]"

Ausgabe: `task.json` (eine User Story mit Prioritäten und Akzeptanzkriterien)

### 2. Re:ZERO Loop ausführen

```bash
./rezero.sh [max_iterations]                        # Claude (Standard)
./rezero.sh --tool amp [max_iterations]             # Amp
./rezero.sh --tool codex [max_iterations]           # OpenAI Codex
./rezero.sh --max-deaths 5 [max_iterations]         # Max. Rückkehr durch den Tod pro Story festlegen
```

Standard-Iterationen: 10, Standard-Max-Tode: 3

**Ausführungsablauf:**

1. Erstellt einen Feature-Branch aus `task.json`
2. Wählt die unvollständige Story mit der höchsten Priorität aus
3. Implementiert die Story
4. Die Teeparty der Hexen führt eine Qualitätsbewertung durch
5. Bei Erfolg: Commit und Statusaktualisierung in `task.json`
6. Bei Misserfolg: Rückkehr durch den Tod wird ausgelöst, Rückkehr zum Checkpoint
7. Zeichnet die gewonnenen Erkenntnisse in `progress.txt` auf
8. Wiederholt sich, bis alle Stories abgeschlossen sind oder die maximale Iterationszahl erreicht ist

## Konzepte

### Natsuki Subaru

Natsuki Subaru ist der Protagonist von Re:Zero.

- In diesem Projekt wird der Agent, der die Arbeit ausführt, als **Natsuki Subaru** bezeichnet.
- Anstatt einfach nur Aufgaben auszuführen, sammelt er durch mehrfache Rückkehr durch den Tod Wissen an.
- Er entwirft jedes Mal einen optimalen Plan, um sein Ziel zu erreichen.

### Rückkehr durch den Tod

![Natsuki Subaru](./images/subaru.webp)

Wenn während der Arbeit eine Anomalie erkannt wird oder die Ergebnisse selbst nach Abschluss unbefriedigend sind, nutzt Natsuki Subaru die Rückkehr durch den Tod, um zu einem Checkpoint zurückzukehren.

- Wird während der Arbeit eine Anomalie erkannt, stoppt er und nutzt die Rückkehr durch den Tod, um zum Checkpoint zurückzukehren.
- Wenn die Teeparty der Hexen feststellt, dass die Erfolgskriterien nicht erfüllt wurden, erzwingt sie eine Rückkehr durch den Tod.
- Die große Bedeutung der Rückkehr durch den Tod liegt darin, dass die Rückkehr zum Checkpoint unter Beibehaltung der Erinnerungen an die Fehlerursache erfolgt.

### Die Teeparty der Hexen

![Die Teeparty der Hexen](./images/witches-tea-party.webp)

Fans, die mit dem Original-Setting vertraut sind, könnten es überraschend finden, dass **die Teeparty der Hexen** als Bewerter fungiert.  
Die Tatsache, dass die sechs Hexen jeweils unterschiedliche Persönlichkeiten haben, kombiniert mit der Spekulation, dass Satella Subarus Checkpoints bestimmen könnte, machte diese Rolle jedoch sehr passend für das Bewertungssystem.

- Nach Abschluss der Arbeit wird „die Teeparty der Hexen" einberufen.
- Die sechs Hexen bewerten die Arbeit aus ihren jeweiligen Perspektiven.
- Satella aggregiert die Bewertungen der sechs Hexen, um zu entscheiden, ob der Checkpoint aktualisiert oder die Rückkehr durch den Tod ausgelöst wird.

| Hexe                    | Bewertungskriterium                                                                                                                                                                                                  |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Echidna (Gier)          | Hat diese Implementierung alle Möglichkeiten erforscht? Sind alle Grenzfälle behandelt? Ist das Wissen gründlich? Praktisch: Prüft Testabdeckung, API-Vollständigkeit, Dokumentation und Behandlung von Randbedingungen. |
| Minerva (Zorn)          | Ist dieser Bug wirklich behoben, oder wurde das Problem nur umverteilt? Erzeugt der Patch neue Fehlermodi in nicht verwandten Funktionen? Führt Regressionstests durch und überprüft, ob die Korrektur nicht verwandte Funktionalität nicht beschädigt. |
| Sekhmet (Faulheit)      | Könnte das gleiche Ergebnis mit weniger Aufwand erreicht werden? Gibt es unnötige Komplexität? Prüft algorithmische Effizienz, redundante Berechnungen und Over-Engineering.                                          |
| Typhon (Hochmut)        | Kennt der Code seine eigenen Sünden? Gibt es absichtlich eingeschlossene Anti-Patterns? Verletzt er seine eigenen Prinzipien? Erkennt Code Smells, Linting-Verstöße und anerkannte, aber nicht behobene technische Schulden. |
| Daphne (Völlerei)       | Wie hungrig ist dieser Code? Ist der Verbrauch von Speicher/CPU/Tokens gerechtfertigt? Prüft Speichernutzung, Anzahl der API-Aufrufe, Bundle-Größe und Token-Verbrauch.                                              |
| Carmilla (Wollust)      | Erfüllt dieser Code das, was der Benutzer wirklich will? Ist die UX ansprechend, oder sind gefährliche Mängel hinter dem Charme verborgen? Bewertet API-Ergonomie, Fehlermeldungen und Übereinstimmung mit der erklärten Absicht des Benutzers. |
| Satella (Neid)          | Der finale Aggregator. Bestimmt, was ein „akzeptables Ergebnis" darstellt, aggregiert die Bewertungen der sechs Hexen mit gewichteten Punktzahlen und fällt das Urteil über Überleben oder Tod: Checkpoint-Durchlass oder Auslösung der Rückkehr durch den Tod. |

### Rem

> **!!! SPOILER-WARNUNG !!!**

![Rem](./images/rem.webp)

Nach der Bezwingung des Weißen Wals wurden Rems Name und Erinnerungen vom Erzbischof der Völlerei verschlungen, woraufhin sie in Scheintod verfiel.  
Der Checkpoint der Rückkehr durch den Tod wurde nach Rems Zustandseintritt fixiert, sodass eine weitere Rückkehr unmöglich wurde.  
Bei der Planung des Re:ZERO Loop führte die Erkenntnis, dass Rems Existenz für dieses Projekt entscheidend sein würde — dass technische Schulden selbst nach dem Bestehen der Teeparty der Hexen bestehen bleiben könnten — zur Aufnahme von Rem in das Projekt.

- Selbst nach dem Bestehen der Teeparty der Hexen bleiben technische Schulden oder Elemente, die zukünftige Korrekturen erfordern, bei der Aktualisierung des Checkpoints bestehen.
- Rem identifiziert und erfasst separat technische Schulden und korrekturbedürftige Elemente.
- Wenn solche Elemente existieren, priorisiert Subaru die Rettung von Rem, bevor er zur nächsten Aufgabe übergeht.

## Lizenz

Dieses Projekt wird unter der [MIT-Lizenz](../LICENSE) verteilt.
