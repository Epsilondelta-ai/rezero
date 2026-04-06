[English](../README.md) | [한국어](./README.ko.md) | [简体中文](./README.zh-CN.md) | [日本語](./README.ja.md) | **Español** | [Português (BR)](./README.pt-BR.md) | [Français](./README.fr.md) | [Русский](./README.ru.md) | [Deutsch](./README.de.md)

# Re:ZERO Loop

![](./images/rezero.webp)

> Re:ZERO Loop es un proyecto inspirado en el **Regreso de la muerte** de **Re:Zero − Empezar de cero en un mundo diferente**.

Para evitar la degradación del rendimiento de la IA causada por la contaminación de contexto acumulado, han surgido técnicas como Ralph Loop.  
Sin embargo, incluso si el contexto se mantiene limpio, si el código acumulado se contamina, la degradación del rendimiento causada por la base de código es inevitable.

Re:ZERO Loop nació de la idea de introducir el Regreso de la muerte en la IA para superar este problema.

## Tabla de contenidos

- [Requisitos previos](#requisitos-previos)
- [Instalación](#instalación)
  - [Opción 1: Copiar directamente al proyecto](#opción-1-copiar-directamente-al-proyecto)
  - [Opción 2: Instalar skills globalmente](#opción-2-instalar-skills-globalmente)
  - [Opción 3: Usar como plugin de Claude Code](#opción-3-usar-como-plugin-de-claude-code)
- [Flujo de trabajo](#flujo-de-trabajo)
  - [1. Crear una definición de tarea](#1-crear-una-definición-de-tarea)
  - [2. Ejecutar el Re:ZERO Loop](#2-ejecutar-el-rezero-loop)
- [Conceptos](#conceptos)
  - [Natsuki Subaru](#natsuki-subaru)
  - [Regreso de la muerte](#regreso-de-la-muerte)
  - [Fiesta del té de las brujas](#fiesta-del-té-de-las-brujas)
  - [Rem](#rem)
- [Licencia](#licencia)

## Requisitos previos

- **Herramienta de codificación con IA** (una de las siguientes):
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
  - [Amp CLI](https://ampcode.com)
  - [OpenAI Codex](https://openai.com/index/codex/)
- **jq** instalado (`brew install jq` en macOS)
- Un **repositorio git** para tu proyecto

## Instalación

### Opción 1: Copiar directamente al proyecto

```bash
mkdir -p scripts/rezero
cp /path/to/rezero/rezero.sh scripts/rezero/
cp /path/to/rezero/subaru.md scripts/rezero/subaru.md
chmod +x scripts/rezero/rezero.sh
```

### Opción 2: Instalar skills globalmente

**Usuarios de Amp:**
```bash
cp -r skills/task ~/.config/amp/skills/
cp -r skills/rezero ~/.config/amp/skills/
cp -r skills/witches-tea-party ~/.config/amp/skills/
cp -r skills/rem ~/.config/amp/skills/
```

**Usuarios de Claude Code:**
```bash
cp -r skills/task ~/.claude/skills/
cp -r skills/rezero ~/.claude/skills/
cp -r skills/witches-tea-party ~/.claude/skills/
cp -r skills/rem ~/.claude/skills/
```

### Opción 3: Usar como plugin de Claude Code

```bash
/plugin marketplace add epsilondelta-ai/rezero
/plugin install rezero-skills@rezero-marketplace
```

Después de la instalación, los skills `/task` y `/rezero` estarán disponibles.

## Flujo de trabajo

### 1. Crear una definición de tarea

Usa el skill task para definir una historia de usuario:

> "Carga el skill task y crea una tarea para [descripción de la funcionalidad]"

Resultado: `task.json` (una historia de usuario con prioridades y criterios de aceptación)

### 2. Ejecutar el Re:ZERO Loop

```bash
./rezero.sh [max_iterations]                        # Claude (por defecto)
./rezero.sh --tool amp [max_iterations]             # Amp
./rezero.sh --tool codex [max_iterations]           # OpenAI Codex
./rezero.sh --max-deaths 5 [max_iterations]         # Establecer máximo de Regreso de la muerte por historia
```

Iteraciones por defecto: 10, máximo de muertes por defecto: 3

**Flujo de ejecución:**

1. Crea una rama de funcionalidad a partir de `task.json`
2. Selecciona la historia incompleta de mayor prioridad
3. Implementa la historia
4. La Fiesta del té de las brujas realiza una evaluación de calidad
5. Si aprueba: hace commit y actualiza el estado en `task.json`
6. Si falla: activa el Regreso de la muerte, volviendo al checkpoint
7. Registra las lecciones aprendidas en `progress.txt`
8. Repite hasta que todas las historias estén completas o se alcance el máximo de iteraciones

## Conceptos

### Natsuki Subaru

Natsuki Subaru es el protagonista de Re:Zero.

- En este proyecto, el agente que realiza el trabajo se denomina **Natsuki Subaru**.
- No se limita a ejecutar tareas, sino que acumula conocimiento a través de múltiples Regresos de la muerte.
- Elabora un plan óptimo en cada intento para alcanzar su objetivo.

### Regreso de la muerte

![Natsuki Subaru](./images/subaru.webp)

Cuando se detecta una anomalía durante el trabajo, o cuando los resultados no son satisfactorios incluso después de completarlo, Natsuki Subaru utiliza el Regreso de la muerte para volver a un checkpoint.

- Si se detecta una anomalía durante el trabajo, se detiene y utiliza el Regreso de la muerte para volver al checkpoint.
- Si la Fiesta del té de las brujas determina que no se han cumplido los criterios de éxito, fuerza un Regreso de la muerte.
- La gran importancia del Regreso de la muerte radica en que vuelve al checkpoint conservando los recuerdos de por qué falló.

### Fiesta del té de las brujas

![Fiesta del té de las brujas](./images/witches-tea-party.webp)

Los fans familiarizados con la ambientación original podrían encontrar sorprendente que la **Fiesta del té de las brujas** sirva como evaluador.  
Sin embargo, el hecho de que las seis brujas tengan personalidades diferentes, combinado con la especulación de que Satella podría determinar los checkpoints de Subaru, hizo que este fuera un rol muy adecuado para el sistema de evaluación.

- Después de completar el trabajo, se convoca la "Fiesta del té de las brujas".
- Las seis brujas evalúan el trabajo desde sus respectivas perspectivas.
- Satella agrega las evaluaciones de las seis brujas para determinar si actualizar el checkpoint o activar el Regreso de la muerte.

| Bruja                 | Criterio de evaluación                                                                                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Echidna (Avaricia)    | ¿Ha explorado esta implementación todas las posibilidades? ¿Se han manejado todos los casos extremos? ¿Es el conocimiento exhaustivo? En la práctica: verifica cobertura de pruebas, completitud de API, documentación y manejo de condiciones límite. |
| Minerva (Ira)         | ¿Se ha corregido realmente este bug, o solo se ha redistribuido el problema? ¿El parche crea nuevos modos de fallo en funcionalidades no relacionadas? Ejecuta pruebas de regresión y verifica que la corrección no rompa funcionalidades no relacionadas. |
| Sekhmet (Pereza)      | ¿Se podría lograr el mismo resultado con menos esfuerzo? ¿Hay complejidad innecesaria? Verifica eficiencia algorítmica, cálculos redundantes y sobreingeniería.                                                         |
| Typhon (Soberbia)     | ¿Conoce el código sus propios pecados? ¿Hay antipatrones incluidos intencionalmente? ¿Viola sus propios principios? Detecta code smells, violaciones de linting y deuda técnica reconocida pero no corregida.            |
| Daphne (Gula)         | ¿Cuánta hambre tiene este código? ¿Está justificado el consumo de memoria/CPU/tokens? Verifica uso de memoria, número de llamadas a API, tamaño del bundle y consumo de tokens.                                         |
| Carmilla (Lujuria)    | ¿Cumple este código con lo que el usuario realmente desea? ¿Es atractiva la UX, o hay defectos peligrosos ocultos tras el encanto? Evalúa la ergonomía de la API, mensajes de error y alineación con la intención declarada del usuario. |
| Satella (Envidia)     | El agregador final. Determina qué constituye un "resultado aceptable", agrega las evaluaciones de las seis brujas usando puntuaciones ponderadas y emite el veredicto de supervivencia o muerte: paso del checkpoint o activación del Regreso de la muerte. |

### Rem

> **!!! ALERTA DE SPOILER !!!**

![Rem](./images/rem.webp)

Después de la subjugación de la Ballena Blanca, Rem tuvo su nombre y recuerdos consumidos por el Arzobispo del Pecado de Gula, cayendo en animación suspendida.  
El checkpoint del Regreso de la muerte quedó fijado después de que Rem cayera en este estado, haciendo imposible retroceder más.  
Al planificar el Re:ZERO Loop, la comprensión de que la existencia de Rem sería crucial para este proyecto — que la deuda técnica podría permanecer incluso después de pasar la Fiesta del té de las brujas — llevó a incorporar a Rem en el proyecto.

- Incluso después de pasar la Fiesta del té de las brujas, si queda deuda técnica o elementos que requieren correcciones futuras, estos persisten al actualizar el checkpoint.
- Rem identifica y registra por separado la deuda técnica y los elementos que necesitan corrección.
- Si existen tales elementos, Subaru prioriza salvar a Rem antes de proceder a la siguiente tarea.

## Licencia

Este proyecto se distribuye bajo la [Licencia MIT](../LICENSE).
