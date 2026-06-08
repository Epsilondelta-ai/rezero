[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | [Português (BR)](./README.pt-BR.md) | **Français** | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop est un workflow d'agents inspiré du **Return by Death** de **Re:ZERO -Starting Life in Another World-**.

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

*Ensuite, installez `rezero` depuis `/plugins` et démarrez une nouvelle session.*

## Utilisation

Dans Pi, Claude Code et Codex :

```text
/rezero:run <task>
```

Codex:

```text
$rezero:run <task>
```

`/rezero:run` vérifie l'état init (marqueur `.rezero/tools.md` + ignore de `.rezero/memory/`). S'il n'existe pas, init est automatiquement exécuté en premier.

## BGM de Return by Death

Quand Re:ZERO Loop effectue un Return by Death, le plugin lit `assets/bgm.mp3` par défaut.

Utilisez `/rezero:run bgm false` ou `/rezero:run bgm off` pour le désactiver dans le projet actuel :

```text
/rezero:run bgm false
/rezero:run bgm off
$rezero:run bgm false
$rezero:run bgm off
```

Utilisez `/rezero:run bgm true` ou `/rezero:run bgm on` pour le réactiver :

```text
/rezero:run bgm true
/rezero:run bgm on
$rezero:run bgm true
$rezero:run bgm on
```

Ces commandes écrivent `.rezero/memory/config.json` :

```json
{
  "bgm": false
}
```

Vous pouvez aussi le désactiver pour une exécution ou dans votre profil shell :

```bash
export REZERO_BGM_DISABLE=1
```

## Workflow

1. Nous donnons une épreuve à Subaru.
2. Subaru fait des efforts pour surmonter l'épreuve.
3. Mais, comme toujours, il peut échouer et faire un Return by Death.  
   Ici, c'est un peu étrange, mais les Sept Sorcières jugent le destin de Subaru.  
   Chacune des Sept Sorcières juge le destin de Subaru avec ses propres indicateurs. Vous pouvez vérifier [ici](#sept-sorcières) quels indicateurs elles utilisent.
4. Si les efforts de Subaru se soldent par un échec et qu'il fait un Return by Death, l'évaluation des Sept Sorcières est mémorisée dans `.rezero/memory/subaru-deaths.md`. (Ce fichier est inclus dans gitignore, il n'est donc pas réinitialisé.)  
   Ensuite, `git reset --hard HEAD` et `git clean -fd` sont exécutés pour effectuer le Return by Death.
5. Subaru répète le processus ci-dessus jusqu'à ce qu'il surmonte cette épreuve. Les fichiers `.rezero/memory/subaru-deaths.md` et `.rezero/memory/rem.md` sont supprimés.
6. Si le checkpoint du Return by Death a été mis à jour après avoir surmonté l'épreuve, mais que certains éléments ont été évalués comme warning par les sorcières, ils sont enregistrés dans `.rezero/memory/rem.md`.
7. Subaru repart dans le voyage ci-dessus afin de sauver Rem.
8. S'il surmonte l'épreuve qui lui a été donnée et réussit à sauver Rem, Subaru peut enfin se reposer après longtemps.

## Concept

### Return by Death

![Subaru](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

Le concept est inspiré du Return by Death de Subaru.  
Il a été emprunté à partir de la question suivante : peut-on vraiment faire les choses correctement avec un contexte déjà désordonné par-dessus un code déjà désordonné ?

### Sept Sorcières

![Witches' Tea Party](./images/witches-tea-party.webp)

En tant que fan de l'œuvre originale, le fait que les Sept Sorcières jugent le destin de Subaru semble un peu étrange,  
mais évaluer sous plusieurs points de vue est une idée plutôt bonne ; le concept a donc été emprunté.

| Sorcière | Axe d'évaluation | Outils d'exemple |
| --- | --- | --- |
| Echidna | Exhaustivité, cas limites, couverture | SonarQube auto-hébergé, coverage, Stryker |
| Typhon | Contrats, spécifications, interfaces publiques | typecheck, linter, Spectral, Pact |
| Minerva | Préjudice utilisateur, régressions, échecs à l'exécution | tests, Playwright, Lighthouse CI, k6 |
| Daphne | Consommation de dépendances/ressources | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Tromperie dans l'UI/la documentation/les noms/les preuves | screenshots, axe, lychee |
| Sekhmet | Maintenabilité, dead code, duplication | SonarQube auto-hébergé, Knip, jscpd |
| Satella | Intégration, sécurité, politique, cohérence | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem (attention aux spoilers)

![Rem](./images/rem.webp)

C'est la principale raison pour laquelle Subaru part en voyage dans l'œuvre originale.  
C'est pour sauver Rem.

Dans l'œuvre originale, même après la réussite de la subjugation de la Baleine Blanche et la mise à jour du checkpoint,  
Rem voit son existence dévorée par l'Archevêque du Péché de la Gourmandise et ne peut plus se réveiller.

Inspiré par ce point, je me suis dit : même si le checkpoint est mis à jour,  
s'il reste des warnings, et si on les considérait comme Rem ?

## Licence

Ce projet est distribué sous la [MIT License](../LICENSE).
