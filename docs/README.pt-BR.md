[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | **Português (BR)** | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

> Re:ZERO Loop é um fluxo de trabalho para agentes inspirado em **Return by Death** de **Re:ZERO -Starting Life in Another World-**.

![](./images/rezero.webp)

## Instalação

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

*Depois, instale `rezero` em `/plugins` e inicie uma nova sessão.*

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

## Fluxo de trabalho

1. Damos uma provação a Subaru.
2. Subaru se esforça para superar a provação.
3. Porém, como sempre, ele pode falhar e fazer Return by Death.  
   Aqui é um pouco estranho, mas as Sete Bruxas julgam o destino de Subaru.  
   Cada uma das Sete Bruxas julga o destino de Subaru usando seus próprios indicadores. Você pode conferir [aqui](#sete-bruxas) quais indicadores elas usam.
4. Se o esforço de Subaru terminar em fracasso e ele fizer Return by Death, a avaliação das Sete Bruxas será lembrada em `.rezero/memory/subaru-deaths.md`. (Esse arquivo está incluído no gitignore, portanto não é resetado.)  
   Depois disso, `git reset --hard HEAD` e `git clean -fd` são executados para realizar o Return by Death.
5. Subaru repete o processo acima até superar essa provação. Os arquivos `.rezero/memory/subaru-deaths.md` e `.rezero/memory/rem.md` são excluídos.
6. Se o checkpoint do Return by Death for atualizado após superar a provação, mas houver itens avaliados pelas bruxas como warning, eles serão registrados em `.rezero/memory/rem.md`.
7. Subaru parte novamente na jornada acima para salvar Rem.
8. Se Subaru superar a provação recebida e conseguir salvar Rem, ele finalmente poderá descansar depois de muito tempo.

## Conceito

### Return by Death

![Subaru](./images/subaru.webp)
```bash
git reset --hard HEAD
git clean -fd
```

Foi inspirado no Return by Death de Subaru.  
Esse conceito foi emprestado a partir da dúvida de se é realmente possível fazer algo direito carregando um contexto bagunçado em cima de um código que já está bagunçado.

### Sete Bruxas

![Witches' Tea Party](./images/witches-tea-party.webp)

Como fã da obra original, o fato de as Sete Bruxas julgarem o destino de Subaru parece um pouco estranho,  
mas avaliar a partir de várias perspectivas é uma ideia bastante boa, então esse conceito foi emprestado.

| Bruxa | Foco | Ferramentas de exemplo |
| --- | --- | --- |
| Echidna | Completude, casos de borda, cobertura | SonarQube auto-hospedado, coverage, Stryker |
| Typhon | Contratos, especificações, interfaces públicas | typecheck, linter, Spectral, Pact |
| Minerva | Danos ao usuário, regressões, falhas em runtime | tests, Playwright, Lighthouse CI, k6 |
| Daphne | Consumo de dependências/recursos | OSV-Scanner, Knip, source-map-explorer, hyperfine |
| Carmilla | Engano em UI/documentação/nomes/provas | screenshots, axe, lychee |
| Sekhmet | Manutenibilidade, dead code, duplicação | SonarQube auto-hospedado, Knip, jscpd |
| Satella | Integração, segurança, política, consistência | CodeQL, Gitleaks, Trivy, CI |

Verdict: `pass`, `warning`, `fail`.

### Rem (cuidado com spoilers)

![Rem](./images/rem.webp)

Ela é o principal motivo pelo qual Subaru parte em sua jornada na obra original.  
É para salvar Rem.

Na obra original, mesmo depois de a subjugação da Baleia Branca ter sido bem-sucedida e o checkpoint ter sido atualizado,  
Rem teve sua existência devorada pelo Arcebispo do Pecado da Gula e não conseguiu mais acordar.

Inspirado por esse ponto, pensei: mesmo que o checkpoint seja atualizado,  
se houver warnings, que tal enxergá-los como Rem?

## Licença

Este projeto é distribuído sob a [MIT License](../LICENSE).
