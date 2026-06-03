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

Call these as parallel subagents.
When spawning witch reviewers, always use the English witch names below as the subagent/team-agent name, display name, and session name.
Do not use localized names, generic reviewer names, numbered names, role-only names, or tool-generated names for witch reviewers.
If the spawn mechanism has no separate display-name field, use the English witch name as the actual spawned agent/member name. For team agents, pass explicit English teammate names. For subagents, choose or create the invocation so the session title/display name is the English witch name, not `subagent-reviewer-*`.

- `references/witches/echidna.md`
- `references/witches/typhon.md`
- `references/witches/minerva.md`
- `references/witches/daphne.md`
- `references/witches/carmilla.md`
- `references/witches/sekhmet.md`
- `references/witches/satella.md`

## Language

Use the user's language for chat prose.
Always use English names for witch reviewer spawning, session/display names, and the verdict table, regardless of the user's language.

English witch names: Echidna, Typhon, Minerva, Daphne, Carmilla, Sekhmet, Satella.

## Anti-Simulation Gate

The lead agent must not invent, simulate, roleplay, summarize-from-memory, or "act as" any witch reviewer.
A witch verdict is valid only if it came from an actual spawned subagent/team-agent/session whose name exactly matches that witch's English name.
Before showing the verdict table, the lead agent must have tool-call evidence that all seven witch agents were spawned and returned.
Acceptable evidence includes a subagent/team tool result, member status/result, mailbox response, or equivalent harness transcript entry that names the witch agent.
If the harness cannot spawn agents, or if any witch did not return, stop and report that the Seven Witches evaluation could not be completed; do not produce a verdict table and do not proceed to reset, retry, Rem, commit, next loop, or final summary.

## Output

After all witch subagents return with spawn/return evidence, the lead agent must aggregate their verdicts and show exactly one table in the assistant chat before any reset, retry, Rem warning handling, commit, next loop, or final summary.
The verdict table is user-visible required output, not internal subagent chatter, task state, team log, or hidden artifact.
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
- No relevant evidence → `warning` minimum; `fail` if that focus is critical to the task.
- Use `fail` only for route-invalidating issues, not preferences.
- One `fail` kills the route.
- Warnings pass but must be sent to Rem.
- The chat verdict table is mandatory before acting on pass/warning/fail outcomes, but only after all seven actual witch agents have returned.
- Never create a verdict row without a returned message from that exact named witch agent.
- If a witch agent is missing, unavailable, failed to spawn, or failed to return, abort the witches step and report the blocker instead of fabricating a verdict.
- Fail/warning outcomes do not justify skipping the table; show it first, then reset/retry or call Rem.
- Keep evidence concise and reproducible.
- Witches judge only; they do not edit code.
- Fresh context is required to avoid confirmation bias.
- Each witch reviewer subagent/team-agent/session display name must exactly match that witch's English name.
- Each witch cleans resources it created before returning.
- If a witch starts a Docker Compose service for evaluation, it must stop that service before returning (for example with the matching `docker compose ... down` command).
