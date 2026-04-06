[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | **Français** | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop est un projet inspiré par la **Mort Réversible** de **Re:Zero − Re:vivre dans un autre monde à partir de zéro**.

Des techniques comme Ralph Loop ont émergé pour empêcher la dégradation des performances de l'IA causée par la pollution du contexte accumulé.  
Cependant, même si le contexte est maintenu propre, si le code accumulé se contamine, la dégradation des performances due à la base de code est inévitable.

Re:ZERO Loop est né de l'idée d'introduire la Mort Réversible dans l'IA pour surmonter ce problème.

## Table des matières

- [Prérequis](#prérequis)
- [Installation](#installation)
  - [Option 1 : Copier directement dans le projet](#option-1--copier-directement-dans-le-projet)
  - [Option 2 : Installer les skills globalement](#option-2--installer-les-skills-globalement)
  - [Option 3 : Utiliser comme plugin Claude Code](#option-3--utiliser-comme-plugin-claude-code)
- [Flux de travail](#flux-de-travail)
  - [1. Créer une définition de tâche](#1-créer-une-définition-de-tâche)
  - [2. Exécuter le Re:ZERO Loop](#2-exécuter-le-rezero-loop)
- [Concepts](#concepts)
  - [Natsuki Subaru](#natsuki-subaru)
  - [Mort Réversible](#mort-réversible)
  - [La fête du thé des sorcières](#la-fête-du-thé-des-sorcières)
  - [Rem](#rem)
- [Licence](#licence)

## Prérequis

- **Outil de codage IA** (l'un des suivants) :
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
  - [OpenAI Codex](https://openai.com/index/codex/)
- **jq** installé (`brew install jq` sur macOS)
- Un **dépôt git** pour votre projet

## Installation

### Option 1 : Copier directement dans le projet

```bash
mkdir -p scripts/rezero
cp /path/to/rezero/rezero.sh scripts/rezero/
cp -r /path/to/rezero/prompts scripts/rezero/prompts
chmod +x scripts/rezero/rezero.sh
```

### Option 2 : Installer les skills globalement

```bash
cp -r skills/task ~/.claude/skills/
cp -r skills/rezero ~/.claude/skills/
cp -r skills/witches-tea-party ~/.claude/skills/
cp -r skills/rem ~/.claude/skills/
```

### Option 3 : Utiliser comme plugin Claude Code

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero-skills@rezero-marketplace
```

Après l'installation, les skills `/task` et `/rezero` deviennent disponibles.

## Flux de travail

### 1. Créer une définition de tâche

Utilisez le skill task pour définir une user story :

> « Chargez le skill task et créez une tâche pour [description de la fonctionnalité] »

Résultat : `task.json` (une user story avec priorités et critères d'acceptation)

### 2. Exécuter le Re:ZERO Loop

```bash
./rezero.sh [max_iterations]                        # Claude (par défaut)
./rezero.sh --tool codex [max_iterations]           # OpenAI Codex
./rezero.sh --max-deaths 5 [max_iterations]         # Définir le max de Mort Réversible par story
```

Itérations par défaut : 10, maximum de morts par défaut : 3

**Flux d'exécution :**

1. Crée une branche de fonctionnalité à partir de `task.json`
2. Sélectionne la story incomplète de plus haute priorité
3. Implémente la story
4. La fête du thé des sorcières effectue une évaluation de qualité
5. En cas de succès : commit et mise à jour du statut dans `task.json`
6. En cas d'échec : déclenche la Mort Réversible, retour au checkpoint
7. Enregistre les leçons apprises dans `progress.txt`
8. Répète jusqu'à ce que toutes les stories soient complètes ou que le nombre maximum d'itérations soit atteint

## Concepts

### Natsuki Subaru

Natsuki Subaru est le protagoniste de Re:Zero.

- Dans ce projet, l'agent qui effectue le travail est nommé **Natsuki Subaru**.
- Plutôt que de simplement exécuter des tâches, il accumule des connaissances à travers de multiples Morts Réversibles.
- Il élabore un plan optimal à chaque tentative pour atteindre son objectif.

### Mort Réversible

![Natsuki Subaru](./images/subaru.webp)

Lorsqu'une anomalie est détectée pendant le travail, ou lorsque les résultats ne sont pas satisfaisants même après l'achèvement, Natsuki Subaru utilise la Mort Réversible pour revenir à un checkpoint.

- Si une anomalie est détectée pendant le travail, il s'arrête et utilise la Mort Réversible pour revenir au checkpoint.
- Si la fête du thé des sorcières détermine que les critères de succès n'ont pas été remplis, elle force une Mort Réversible.
- La grande importance de la Mort Réversible réside dans le fait qu'elle permet de revenir au checkpoint en conservant les souvenirs de la raison de l'échec.

### La fête du thé des sorcières

![La fête du thé des sorcières](./images/witches-tea-party.webp)

Les fans familiarisés avec l'univers original pourraient trouver surprenant que **la fête du thé des sorcières** serve d'évaluateur.  
Cependant, le fait que les six sorcières aient chacune des personnalités différentes, combiné à la spéculation que Satella pourrait déterminer les checkpoints de Subaru, a rendu ce rôle très adapté au système d'évaluation.

- Après l'achèvement du travail, « la fête du thé des sorcières » est convoquée.
- Les six sorcières évaluent le travail depuis leurs perspectives respectives.
- Satella agrège les évaluations des six sorcières pour déterminer s'il faut mettre à jour le checkpoint ou déclencher la Mort Réversible.

| Sorcière              | Critère d'évaluation                                                                                                                                                                                                 |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Echidna (Avarice)     | Cette implémentation a-t-elle exploré toutes les possibilités ? Tous les cas limites sont-ils traités ? La connaissance est-elle exhaustive ? En pratique : vérifie la couverture de tests, la complétude de l'API, la documentation et la gestion des conditions aux limites. |
| Minerva (Colère)      | Ce bug est-il vraiment corrigé, ou le problème a-t-il simplement été redistribué ? Le correctif crée-t-il de nouveaux modes de défaillance dans des fonctionnalités non liées ? Exécute des tests de régression et vérifie que la correction ne casse pas de fonctionnalités non liées. |
| Sekhmet (Paresse)     | Le même résultat pourrait-il être atteint avec moins d'effort ? Y a-t-il une complexité inutile ? Vérifie l'efficacité algorithmique, les calculs redondants et la sur-ingénierie.                                   |
| Typhon (Orgueil)      | Le code connaît-il ses propres péchés ? Y a-t-il des anti-patterns inclus intentionnellement ? Viole-t-il ses propres principes ? Détecte les code smells, les violations de linting et la dette technique reconnue mais non corrigée. |
| Daphne (Gourmandise)  | Quelle est la faim de ce code ? La consommation de mémoire/CPU/tokens est-elle justifiée ? Vérifie l'utilisation mémoire, le nombre d'appels API, la taille du bundle et la consommation de tokens.                  |
| Carmilla (Luxure)     | Ce code répond-il à ce que l'utilisateur veut vraiment ? L'UX est-elle attrayante, ou des défauts dangereux sont-ils cachés derrière le charme ? Évalue l'ergonomie de l'API, les messages d'erreur et l'alignement avec l'intention déclarée de l'utilisateur. |
| Satella (Envie)       | L'agrégateur final. Détermine ce qui constitue un « résultat acceptable », agrège les évaluations des six sorcières en utilisant des scores pondérés et rend le verdict de survie ou de mort : passage du checkpoint ou déclenchement de la Mort Réversible. |

### Rem

> **!!! ALERTE SPOILER !!!**

![Rem](./images/rem.webp)

Après la subjugation de la Baleine Blanche, Rem a eu son nom et ses souvenirs dévorés par l'Archevêque de la Gourmandise, tombant en animation suspendue.  
Le checkpoint de la Mort Réversible s'est fixé après que Rem soit tombée dans cet état, rendant impossible tout retour en arrière.  
En planifiant le Re:ZERO Loop, la prise de conscience que l'existence de Rem serait cruciale pour ce projet — que la dette technique pourrait persister même après avoir passé la fête du thé des sorcières — a conduit à intégrer Rem dans le projet.

- Même après avoir passé la fête du thé des sorcières, si de la dette technique ou des éléments nécessitant des corrections futures subsistent, ils persistent lors de la mise à jour du checkpoint.
- Rem identifie et enregistre séparément la dette technique et les éléments nécessitant des corrections.
- Si de tels éléments existent, Subaru priorise le sauvetage de Rem avant de passer à la tâche suivante.

## Licence

Ce projet est distribué sous la [Licence MIT](../LICENSE).
