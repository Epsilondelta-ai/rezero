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

Call these as parallel subagents using the witch alias as the actual pi `agent` value, not generic `reviewer` with a witch role in the task text. This makes targets like `subagent-echidna-...`.

- `echidna` → `references/witches/echidna.md`
- `typhon` → `references/witches/typhon.md`
- `minerva` → `references/witches/minerva.md`
- `daphne` → `references/witches/daphne.md`
- `carmilla` → `references/witches/carmilla.md`
- `sekhmet` → `references/witches/sekhmet.md`
- `satella` → `references/witches/satella.md`

If an alias is missing, create a project prompt-agent alias. Do not modify pi-subagents plugin code.
Do not use localized names, generic reviewer names, numbered names, role-only names, or tool-generated names for witch reviewers.

## Language

Use the user's language for chat prose.
Always use English names for witch reviewer spawning, session/display names, and the verdict table, regardless of the user's language.

English witch names: Echidna, Typhon, Minerva, Daphne, Carmilla, Sekhmet, Satella.

## Anti-Simulation Gate

The lead agent must not invent, simulate, roleplay, summarize-from-memory, or "act as" any witch reviewer.
A witch verdict is valid only if it came from an actual spawned subagent/session whose name matches that witch's English name or pi alias.
Before showing the verdict table, the lead agent must have tool-call evidence that all seven witch agents were spawned and returned.
Acceptable evidence includes a subagent tool result, mailbox response, or equivalent harness transcript entry that names the witch agent/alias.
If the harness cannot spawn agents, or if any witch did not return, stop and report that the Seven Witches evaluation could not be completed; do not produce a verdict table and do not proceed to reset, retry, Rem, commit, next loop, or final summary.

## Output

After all witch subagents return with spawn/return evidence, the lead agent must aggregate their verdicts and show exactly one table in the assistant chat before any reset, retry, Rem warning handling, commit, next loop, or final summary.
The verdict table is user-visible required output, not internal subagent chatter, task state, or hidden artifact.
Do not omit it, defer it, replace it with prose, or keep it only in task/subagent logs.
If any witch returns `fail` or `warning`, the table is still mandatory before starting the next loop or warning-resolution work.

```markdown
| witch | verdict | reason | evidence |
|---|---|---|---|
| <name> | pass/warning/fail | <short reason> | <command/output/file> |
```

## Rules

- Verdict values only: `pass`, `warning`, `fail`.
- Judge evidence, not effort.
- Default posture is skeptical and proportionate: look for evidence, but do not punish harmless uncertainty.
- `pass` requires positive, reproducible evidence covering the witch's focus and material changed surfaces.
- No relevant evidence, skipped relevant tools, or unverified material changes → `warning` minimum.
- Missing evidence on user-visible behavior, security, data integrity, public contracts, CI/type/lint/test gates, or the user's core requirement → `fail` only when the gap is material to acceptance or safety.
- Use `fail` for issues that invalidate acceptance, break a required gate, make verification non-reproducible, or leave a critical risk unresolved.
- Do not downgrade a required failure to `warning` because the implementation effort looks plausible, the issue seems easy to fix, or no tool was available.
- Do not upgrade minor style issues, hypothetical risks, unavailable optional tools, or bounded non-critical uncertainty to `fail`.
- One `fail` kills the route.
- Warnings are not success; they allow the route to continue only when the concern is bounded and Rem records the debt.
- The chat verdict table is mandatory before acting on pass/warning/fail outcomes, but only after all seven actual witch agents have returned.
- Never create a verdict row without a returned message from that exact named witch agent.
- If a witch agent is missing, unavailable, failed to spawn, or failed to return, abort the witches step and report the blocker instead of fabricating a verdict.
- Fail/warning outcomes do not justify skipping the table; show it first, then reset/retry or call Rem.
- Keep evidence concise and reproducible.
- Witches judge only; they do not edit code.
- Fresh context is required to avoid confirmation bias.
- In pi `subagent(...)`, each witch reviewer must use its lowercase alias as the runtime `agent` value.
- Each witch cleans resources it created before returning.
- If a witch starts a Docker Compose service for evaluation, it must stop that service before returning (for example with the matching `docker compose ... down` command).
