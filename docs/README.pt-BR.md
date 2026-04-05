[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | [Español](./README.es.md) | **Português (BR)** | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop é um projeto inspirado no **Retorno pela Morte** de **Re:Zero − Começando uma Vida em Outro Mundo**.

Técnicas como o Ralph Loop surgiram para evitar a degradação do desempenho da IA causada pela poluição de contexto acumulado.  
No entanto, mesmo mantendo o contexto limpo, se o código acumulado se contaminar, a degradação de desempenho causada pela base de código é inevitável.

O Re:ZERO Loop nasceu da ideia de introduzir o Retorno pela Morte na IA para superar esse problema.

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
  - [Opção 1: Copiar diretamente para o projeto](#opção-1-copiar-diretamente-para-o-projeto)
  - [Opção 2: Instalar skills globalmente](#opção-2-instalar-skills-globalmente)
  - [Opção 3: Usar como plugin do Claude Code](#opção-3-usar-como-plugin-do-claude-code)
- [Fluxo de trabalho](#fluxo-de-trabalho)
  - [1. Criar uma definição de tarefa](#1-criar-uma-definição-de-tarefa)
  - [2. Executar o Re:ZERO Loop](#2-executar-o-rezero-loop)
- [Conceitos](#conceitos)
  - [Natsuki Subaru](#natsuki-subaru)
  - [Retorno pela Morte](#retorno-pela-morte)
  - [Festa do Chá das Bruxas](#festa-do-chá-das-bruxas)
  - [Rem](#rem)
- [Licença](#licença)

## Pré-requisitos

- **Ferramenta de codificação com IA** (uma das seguintes):
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
  - [Amp CLI](https://ampcode.com)
  - [OpenAI Codex](https://openai.com/index/codex/)
- **jq** instalado (`brew install jq` no macOS)
- Um **repositório git** para seu projeto

## Instalação

### Opção 1: Copiar diretamente para o projeto

```bash
mkdir -p scripts/rezero
cp /path/to/rezero/rezero.sh scripts/rezero/
cp /path/to/rezero/prompt.md scripts/rezero/prompt.md
chmod +x scripts/rezero/rezero.sh
```

### Opção 2: Instalar skills globalmente

**Usuários do Amp:**
```bash
cp -r skills/task ~/.config/amp/skills/
cp -r skills/rezero ~/.config/amp/skills/
cp -r skills/witches-tea-party ~/.config/amp/skills/
cp -r skills/rem ~/.config/amp/skills/
```

**Usuários do Claude Code:**
```bash
cp -r skills/task ~/.claude/skills/
cp -r skills/rezero ~/.claude/skills/
cp -r skills/witches-tea-party ~/.claude/skills/
cp -r skills/rem ~/.claude/skills/
```

### Opção 3: Usar como plugin do Claude Code

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero-skills@rezero-marketplace
```

Após a instalação, os skills `/task` e `/rezero` ficam disponíveis.

## Fluxo de trabalho

### 1. Criar uma definição de tarefa

Use o skill task para definir uma história de usuário:

> "Carregue o skill task e crie uma tarefa para [descrição da funcionalidade]"

Saída: `task.json` (uma história de usuário com prioridades e critérios de aceitação)

### 2. Executar o Re:ZERO Loop

```bash
./rezero.sh [max_iterations]                        # Claude (padrão)
./rezero.sh --tool amp [max_iterations]             # Amp
./rezero.sh --tool codex [max_iterations]           # OpenAI Codex
./rezero.sh --max-deaths 5 [max_iterations]         # Definir máximo de Retorno pela Morte por história
```

Iterações padrão: 10, máximo de mortes padrão: 3

**Fluxo de execução:**

1. Cria uma branch de funcionalidade a partir do `task.json`
2. Seleciona a história incompleta de maior prioridade
3. Implementa a história
4. A Festa do Chá das Bruxas realiza uma avaliação de qualidade
5. Se aprovado: faz commit e atualiza o status no `task.json`
6. Se reprovado: aciona o Retorno pela Morte, voltando ao checkpoint
7. Registra as lições aprendidas no `progress.txt`
8. Repete até que todas as histórias estejam completas ou o máximo de iterações seja alcançado

## Conceitos

### Natsuki Subaru

Natsuki Subaru é o protagonista de Re:Zero.

- Neste projeto, o agente que executa o trabalho é chamado de **Natsuki Subaru**.
- Ao invés de simplesmente executar tarefas, acumula conhecimento através de múltiplos Retornos pela Morte.
- Elabora um plano ótimo a cada tentativa para alcançar seu objetivo.

### Retorno pela Morte

![Natsuki Subaru](./images/subaru.webp)

Quando uma anomalia é detectada durante o trabalho, ou quando os resultados não são satisfatórios mesmo após a conclusão, Natsuki Subaru usa o Retorno pela Morte para voltar a um checkpoint.

- Se uma anomalia é detectada durante o trabalho, ele para e usa o Retorno pela Morte para voltar ao checkpoint.
- Se a Festa do Chá das Bruxas determina que os critérios de sucesso não foram atendidos, força um Retorno pela Morte.
- O grande significado do Retorno pela Morte é que ele retorna ao checkpoint mantendo as memórias de por que falhou.

### Festa do Chá das Bruxas

![Festa do Chá das Bruxas](./images/witches-tea-party.webp)

Fãs familiarizados com a ambientação original podem achar surpreendente que a **Festa do Chá das Bruxas** sirva como avaliador.  
No entanto, o fato de que as seis bruxas possuem personalidades diferentes, combinado com a especulação de que Satella pode determinar os checkpoints de Subaru, tornou esse papel muito adequado para o sistema de avaliação.

- Após a conclusão do trabalho, a "Festa do Chá das Bruxas" é convocada.
- As seis bruxas avaliam o trabalho a partir de suas respectivas perspectivas.
- Satella agrega as avaliações das seis bruxas para determinar se atualiza o checkpoint ou aciona o Retorno pela Morte.

| Bruxa                 | Critério de avaliação                                                                                                                                                                                                 |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Echidna (Avareza)     | Esta implementação explorou todas as possibilidades? Todos os casos extremos foram tratados? O conhecimento é completo? Na prática: verifica cobertura de testes, completude da API, documentação e tratamento de condições de contorno. |
| Minerva (Ira)         | Este bug foi realmente corrigido, ou o problema foi apenas redistribuído? O patch cria novos modos de falha em funcionalidades não relacionadas? Executa testes de regressão e verifica se a correção não quebra funcionalidades não relacionadas. |
| Sekhmet (Preguiça)    | O mesmo resultado poderia ser alcançado com menos esforço? Existe complexidade desnecessária? Verifica eficiência algorítmica, computações redundantes e engenharia excessiva.                                         |
| Typhon (Soberba)      | O código conhece seus próprios pecados? Existem antipadrões incluídos intencionalmente? Viola seus próprios princípios? Detecta code smells, violações de linting e dívida técnica reconhecida mas não corrigida.      |
| Daphne (Gula)         | Quão faminto está este código? O consumo de memória/CPU/tokens é justificado? Verifica uso de memória, número de chamadas de API, tamanho do bundle e consumo de tokens.                                              |
| Carmilla (Luxúria)    | Este código atende ao que o usuário realmente deseja? A UX é atraente, ou há falhas perigosas escondidas por trás do charme? Avalia ergonomia da API, mensagens de erro e alinhamento com a intenção declarada do usuário. |
| Satella (Inveja)      | O agregador final. Determina o que constitui um "resultado aceitável", agrega as avaliações das seis bruxas usando pontuações ponderadas e emite o veredicto de sobrevivência ou morte: passagem do checkpoint ou acionamento do Retorno pela Morte. |

### Rem

> **!!! ALERTA DE SPOILER !!!**

![Rem](./images/rem.webp)

Após a subjugação da Baleia Branca, Rem teve seu nome e memórias consumidos pelo Arcebispo da Gula, caindo em animação suspensa.  
O checkpoint do Retorno pela Morte ficou fixado após Rem cair nesse estado, tornando impossível retornar mais no tempo.  
Ao planejar o Re:ZERO Loop, a percepção de que a existência de Rem seria crucial para este projeto — que a dívida técnica poderia permanecer mesmo após passar pela Festa do Chá das Bruxas — levou à incorporação de Rem ao projeto.

- Mesmo após passar pela Festa do Chá das Bruxas, se houver dívida técnica ou itens que necessitem de correções futuras, eles persistem quando o checkpoint é atualizado.
- Rem identifica e registra separadamente a dívida técnica e os itens que precisam de correção.
- Se tais itens existirem, Subaru prioriza salvar Rem antes de prosseguir para a próxima tarefa.

## Licença

Este projeto é distribuído sob a [Licença MIT](../LICENSE).
