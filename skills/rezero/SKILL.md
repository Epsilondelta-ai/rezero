---
name: rezero
description: Orchestrate the Re:ZERO Loop. Use for /rezero requests: split large work, let Subaru implement, call Seven Witches, send warnings to Rem, reset on fail, and commit on pass.
license: MIT
---

# Re:ZERO

Goal → finish request through small Re:ZERO attempts.

## Flow

0. If request is `init`, use `rezero-init` and stop.
1. Before any non-init request, check init state:
   - `.rezero/tools.md` exists.
   - `.rezero/tools.md` contains `<!-- rezero-init:`.
   - `git check-ignore -q .rezero/memory/subaru-deaths.md` succeeds.
2. If init state is missing, run `rezero-init`, commit init changes, then continue the original request.
3. If request is large, use `rezero-plan`; otherwise one task.
4. If planned tasks are independent, run safe groups in parallel via subagents; use team agents for long/heavy groups.
5. Isolate parallel implementation work, merge the group, then verify the combined result.
6. Use `rezero-witches` once for the whole merged group; witches must use fresh context, not Subaru's context.
7. Show the witch verdict table in chat.
8. Any `fail` → record minimal death memory → `git reset --hard HEAD` → `git clean -fd` → retry with changed route.
9. Only `pass|warning` → use `rezero-rem` for warnings → commit accepted route → delete death memory.
10. If processing Rem warnings, use `rezero-rem` resolution rules.

## Language

Use the user's language for chat output and agent display names.
Supported languages: English, Korean, Japanese, Simplified Chinese, Spanish, Portuguese, French, Russian, German.
If the language is unsupported, use English.

Parallel implementer names are names only; no character behavior.

| Language | Parallel implementer names |
| --- | --- |
| English / Spanish / Portuguese / German | Beatrice, Emilia, Ram, Garfiel, Julius |
| Korean | 베아트리스, 에밀리아, 람, 가필, 율리우스 |
| Japanese | ベアトリス, エミリア, ラム, ガーフィール, ユリウス |
| Simplified Chinese | 碧翠丝, 艾米莉娅, 拉姆, 加菲尔, 尤里乌斯 |
| French | Béatrice, Émilia, Ram, Garfiel, Julius |
| Russian | Беатрис, Эмилия, Рам, Гарфиэль, Юлиус |

## Death Memory

Before reset, append to `.rezero/memory/subaru-deaths.md`:

```markdown
## Death <number>

- Fail: <witch + reason>
- Evidence: <minimal test/review/error/defect>
- Next route: <specific change>
```

## Rules

- Sequential task = implement → verify → witches → commit or reset.
- Parallel group = parallel implement → merge → verify combined result → one witches evaluation → one commit or reset.
- Parallel implementer names must follow the supported-language name map; names only, no character behavior.
- Do not parallelize tasks that touch the same files, migrations, shared state, or dependency graph.
- Never reset before death memory.
- Never retry without new info.
- Dangerous ambiguity → ask 1 focused question.
