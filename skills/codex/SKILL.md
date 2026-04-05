# Codex — OpenAI Codex CLI Integration

Enables the Re:ZERO Loop to use [OpenAI Codex CLI](https://github.com/openai/codex) as an autonomous coding agent alongside Claude and Amp.

## Prerequisites

- Codex CLI installed: `npm install -g @openai/codex`
- `OPENAI_API_KEY` environment variable set

## Usage

```bash
./rezero.sh --tool codex [--max-deaths N] [max_iterations]
```

## How It Works

Codex CLI runs in `--full-auto` mode, which allows it to:
- Read and write files
- Execute shell commands
- Make code changes autonomously

The Re:ZERO prompt is passed directly as a positional argument to `codex`. The `--quiet` flag suppresses interactive UI, making it suitable for scripted loops.

## Behavior Differences

| Feature | Claude | Amp | Codex |
|---------|--------|-----|-------|
| Input method | stdin pipe | stdin pipe | positional argument |
| Auto-approve | `--dangerously-skip-permissions --print` | `--dangerously-allow-all` | `--full-auto --quiet` |
| Model | Claude (Anthropic) | Amp | GPT-4.1 (OpenAI) |

## Notes

- Codex CLI uses `--full-auto` to approve all file writes and command executions without prompting.
- `--quiet` disables the interactive TUI so output can be captured by the loop.
- The completion and blocked signals (`<promise>COMPLETE</promise>`, `<promise>BLOCKED</promise>`) work the same way — Codex will output them as part of its response when following the Re:ZERO prompt instructions.
- All Re:ZERO skills (task, rezero, witches-tea-party, rem) are tool-agnostic and work with Codex without modification.
