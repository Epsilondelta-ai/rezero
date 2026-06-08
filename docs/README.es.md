[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | **Español** | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop es un flujo de trabajo para agentes inspirado en **Return by Death** de **Re:ZERO -Starting Life in Another World-**.

![](./images/rezero.webp)

## Instalación

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

*Después, instala `rezero` desde `/plugins` e inicia una nueva sesión.*

## Uso

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

## BGM de Return by Death

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

## Flujo de trabajo

1. Le damos una prueba a Subaru.
2. Subaru se esfuerza para superar la prueba.
3. Pero, como siempre, puede fracasar y hacer Return by Death.  
   Aquí resulta un poco extraño, pero las Siete Brujas juzgan el destino de Subaru.  
   Cada una de las Siete Brujas juzga el destino de Subaru con sus propios indicadores. Puedes comprobar [aquí](#siete-brujas) con qué indicadores juzgan.
4. Si el esfuerzo de Subaru termina en fracaso y hace Return by Death, la evaluación de las Siete Brujas se recuerda en `.rezero/memory/subaru-deaths.md`. (Ese archivo está incluido en gitignore, por lo que no se restablece).  
   Después se ejecutan `git reset --hard HEAD` y `git clean -fd` para realizar Return by Death.
5. Subaru repite el proceso anterior hasta superar esta prueba. Se eliminan los archivos `.rezero/memory/subaru-deaths.md` y `.rezero/memory/rem.md`.
6. Si, aunque el checkpoint de Return by Death se haya actualizado tras superar la prueba, hay elementos que las brujas evaluaron como warning, se registran en `.rezero/memory/rem.md`.
7. Subaru vuelve a emprender el viaje anterior para salvar a Rem.
8. Si supera la prueba que se le dio y logra salvar a Rem, Subaru por fin descansa después de mucho tiempo.

## Concepto

### Return by Death

![Subaru](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

Está inspirado en el Return by Death de Subaru.  
Tomé prestado este concepto a partir de la duda de si realmente se puede hacer bien algo con un contexto desordenado encima de un código que ya está desordenado.

### Siete Brujas

![Witches' Tea Party](./images/witches-tea-party.webp)

Como fan de la obra original, que las Siete Brujas juzguen el destino de Subaru se siente un poco extraño,  
pero evaluar desde múltiples puntos de vista es una idea bastante buena, así que tomé prestado el concepto.

| Bruja | Enfoque | Herramientas de ejemplo |
| --- | --- | --- |
| Echidna | Completitud, casos límite, cobertura | SonarQube autohospedado, coverage, Stryker |
| Typhon | Contratos, especificaciones, interfaces públicas | typecheck, linter, Spectral, Pact |
| Minerva | Daño al usuario, regresiones, fallos en tiempo de ejecución | tests, Playwright, Lighthouse CI, k6 |
| Daphne | Consumo de dependencias/recursos | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Engaño en UI/documentación/nombres/pruebas | screenshots, axe, lychee |
| Sekhmet | Mantenibilidad, dead code, duplicación | SonarQube autohospedado, Knip, jscpd |
| Satella | Integración, seguridad, políticas, consistencia | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem (cuidado: spoilers)

![Rem](./images/rem.webp)

Es la razón principal por la que Subaru emprende su viaje en la obra original.  
Lo hace para salvar a Rem.

En la obra original, aunque la subyugación de la Ballena Blanca tuvo éxito y el checkpoint se actualizó,  
Rem perdió su existencia, devorada por el Arzobispo del Pecado de la Gula, y ya no pudo despertar.

Inspirado por ese punto, pensé: aunque el checkpoint se haya actualizado,  
si hay warnings, ¿qué tal si los vemos como Rem?

## Licencia

Este proyecto se distribuye bajo la [MIT License](../LICENSE).
