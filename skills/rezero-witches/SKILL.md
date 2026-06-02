---
name: rezero-witches
description: Run the Seven Witches evaluation for a Re:ZERO attempt. Use after Subaru implements and verifies a task to get independent pass/warning/fail verdicts.
license: MIT
---

# Re:ZERO Witches

Goal → call seven independent reviewers with fresh context and expose verdicts as a chat table.

## Inputs

Each witch must run in a fresh context, not Subaru's context.
Give each witch only:

- Task/request.
- Current diff.
- Verification output.
- Relevant files or logs.
- Its own reference file from `references/witches/`.

Do not give witches Subaru's reasoning, plan, self-assessment, or prior failed route unless it is required evidence.

## Witches

Call these as parallel subagents:

- `references/witches/echidna.md`
- `references/witches/typhon.md`
- `references/witches/minerva.md`
- `references/witches/daphne.md`
- `references/witches/carmilla.md`
- `references/witches/sekhmet.md`
- `references/witches/satella.md`

## Language

Use the user's language for chat output.
Witch names in the verdict table must use the supported-language name map.
If the language is unsupported, use English names.

| Language | Echidna | Typhon | Minerva | Daphne | Carmilla | Sekhmet | Satella |
| --- | --- | --- | --- | --- | --- | --- | --- |
| English / Spanish / Portuguese / German | Echidna | Typhon | Minerva | Daphne | Carmilla | Sekhmet | Satella |
| Korean | 에키드나 | 티폰 | 미네르바 | 다프네 | 카밀라 | 세크메트 | 사테라 |
| Japanese | エキドナ | テュフォン | ミネルヴァ | ダフネ | カーミラ | セクメト | サテラ |
| Simplified Chinese | 艾姬多娜 | 堤丰 | 弥涅耳瓦 | 达芙妮 | 卡密拉 | 塞赫麦特 | 莎缇拉 |
| French | Echidna | Typhon | Minerva | Daphné | Carmilla | Sekhmet | Satella |
| Russian | Ехидна | Тифон | Минерва | Дафна | Кармилла | Сехмет | Сателла |

## Output

Show exactly one table in chat:

```markdown
| witch | verdict | reason | evidence |
|---|---|---|---|
| <name> | pass/warning/fail | <short reason> | <command/output/file> |
```

## Rules

- Verdict values only: `pass`, `warning`, `fail`.
- One `fail` kills the route.
- Warnings pass but must be sent to Rem.
- Keep evidence concise and reproducible.
- Witches judge only; they do not edit code.
- Fresh context is required to avoid confirmation bias.
- Each witch cleans resources it created before returning.
