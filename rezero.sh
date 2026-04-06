#!/bin/bash
# Re:ZERO Loop - Autonomous AI agent loop
# Implements user stories from task.json one at a time,
# accumulating knowledge across iterations via progress.txt.
#
# Usage: ./rezero.sh [--tool claude|codex] [--max-deaths N] [max_iterations]

set -e

# Parse arguments
TOOL="claude"  # Default to claude
MAX_ITERATIONS=10
MAX_DEATHS=3

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --tool=*)
      TOOL="${1#*=}"
      shift
      ;;
    --max-deaths)
      MAX_DEATHS="$2"
      shift 2
      ;;
    --max-deaths=*)
      MAX_DEATHS="${1#*=}"
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

# Validate tool choice
if [[ "$TOOL" != "claude" && "$TOOL" != "codex" ]]; then
  echo "Error: Invalid tool '$TOOL'. Must be 'claude' or 'codex'."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_FILE="$SCRIPT_DIR/task.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
REM_FILE="$SCRIPT_DIR/rem.md"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"

# Archive previous run if branch changed
if [ -f "$TASK_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$TASK_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    DATE=$(date +%Y-%m-%d)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^rezero/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$TASK_FILE" ] && cp "$TASK_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$REM_FILE" ] && cp "$REM_FILE" "$ARCHIVE_FOLDER/"
    echo "  Archived to: $ARCHIVE_FOLDER"

    # Reset progress file for new run
    echo "# Re:ZERO Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Track current branch
if [ -f "$TASK_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$TASK_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Re:ZERO Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

echo ""
echo "  ____        __________ ____   ___"
echo " |  _ \\ ___  |__  / ____|  _ \\ / _ \\"
echo " | |_) / _ \\   / /|  _| | |_) | | | |"
echo " |  _ <  __/  / /_| |___|  _ <| |_| |"
echo " |_| \\_\\___| /____|_____|_| \\_\\\\___/"
echo ""
echo " Tool: $TOOL | Max iterations: $MAX_ITERATIONS | Max deaths: $MAX_DEATHS"
echo ""

DEATH_COUNT=0

# Helper: run agent with a prompt template, return output in $OUTPUT and exit code in $EXIT_CODE
run_agent() {
  local PROMPT="$1"
  local LABEL="$2"
  EXIT_CODE=0
  if [[ "$TOOL" == "codex" ]]; then
    STREAM_FILE=$(mktemp)
    {
      echo "$PROMPT" | codex exec --full-auto --json - 2>/dev/null | \
        tee "$STREAM_FILE" | \
        jq --unbuffered -r '
          if .type == "item.completed" then
            if .item.type == "agent_message" then .item.text
            else "  \u25b6 \(.item.name // .item.type)"
            end
          else empty end
        ' >&2
    } || EXIT_CODE=$?
    OUTPUT=$(jq -rs '[.[] | select(.type == "item.completed" and .item.type == "agent_message") | .item.text] | join("\n")' "$STREAM_FILE" 2>/dev/null || echo "")
    rm -f "$STREAM_FILE"
  else
    STREAM_FILE=$(mktemp)
    {
      echo "$PROMPT" | claude --dangerously-skip-permissions --print --verbose \
        --output-format stream-json 2>/dev/null | \
        tee "$STREAM_FILE" | \
        jq --unbuffered -r '
          if .type == "assistant" then
            [.message.content[]? |
              if .type == "tool_use" then "  \u25b6 \(.name)"
              elif .type == "text" then .text
              else empty end
            ] | join("\n") | select(length > 0)
          else empty end
        ' >&2
    } || EXIT_CODE=$?
    OUTPUT=$(jq -r 'select(.type == "result") | .result // empty' "$STREAM_FILE" 2>/dev/null || echo "")
    rm -f "$STREAM_FILE"
  fi
}

# Helper: check if agent crashed and handle crash logic. Returns 0 if crash handled, 1 if not a crash.
handle_crash() {
  local LABEL="$1"
  local HAS_COMPLETE=false
  local HAS_BLOCKED=false
  local HAS_IMPLEMENTED=false
  echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>" && HAS_COMPLETE=true
  echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>" && HAS_BLOCKED=true
  echo "$OUTPUT" | grep -q "<promise>IMPLEMENTED</promise>" && HAS_IMPLEMENTED=true

  if [[ $EXIT_CODE -ne 0 ]] && ! $HAS_COMPLETE && ! $HAS_BLOCKED && ! $HAS_IMPLEMENTED; then
    DEATH_COUNT=$((DEATH_COUNT + 1))
    echo ""
    echo "WARNING: $LABEL crashed with exit code $EXIT_CODE (death $DEATH_COUNT/$MAX_DEATHS)"
    echo "---" >> "$PROGRESS_FILE"
    echo "CRASH at iteration $i ($LABEL): Agent exited with code $EXIT_CODE (death $DEATH_COUNT/$MAX_DEATHS)" >> "$PROGRESS_FILE"
    echo "Time: $(date)" >> "$PROGRESS_FILE"

    if [[ $DEATH_COUNT -ge $MAX_DEATHS ]]; then
      echo ""
      echo "Re:ZERO Loop aborted: Agent crashed $DEATH_COUNT times (max deaths: $MAX_DEATHS)."
      echo "Check $PROGRESS_FILE for details."
      echo "ABORTED: Reached max deaths ($MAX_DEATHS) at iteration $i" >> "$PROGRESS_FILE"
      exit 3
    fi
    return 0
  fi
  return 1
}

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Re:ZERO Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "==============================================================="

  # ── Phase 1: Implementation (Subaru) ──────────────────────────────
  echo ""
  echo "  Phase 1: Implementation"
  echo "  ───────────────────────"

  IMPL_PROMPT=$(sed "s/{{MAX_DEATHS}}/$MAX_DEATHS/g" "$SCRIPT_DIR/subaru.md")
  run_agent "$IMPL_PROMPT" "Implementation"

  # Handle crash
  if handle_crash "Implementation"; then
    echo "Retrying after crash..."
    sleep 2
    continue
  fi

  # Check for completion signal
  HAS_COMPLETE=false
  HAS_BLOCKED=false
  HAS_IMPLEMENTED=false
  echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>" && HAS_COMPLETE=true
  echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>" && HAS_BLOCKED=true
  echo "$OUTPUT" | grep -q "<promise>IMPLEMENTED</promise>" && HAS_IMPLEMENTED=true

  if $HAS_COMPLETE; then
    echo ""
    echo "Re:ZERO Loop complete! All stories passed."
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  if $HAS_BLOCKED; then
    echo ""
    echo "Re:ZERO Loop blocked. User intervention needed."
    echo "Blocked at iteration $i of $MAX_ITERATIONS"
    echo "Check $PROGRESS_FILE for details."
    exit 2
  fi

  # If not IMPLEMENTED, this was an early abort/story split — skip evaluation
  if ! $HAS_IMPLEMENTED; then
    DEATH_COUNT=0
    echo "Implementation aborted early. Continuing to next iteration..."
    sleep 2
    continue
  fi

  # ── Phase 2: Evaluation (Witches' Tea Party) ──────────────────────
  echo ""
  echo "  Phase 2: Witches' Tea Party (마녀들의 다과회)"
  echo "  ─────────────────────────────────────────────"

  EVAL_PROMPT=$(sed "s/{{MAX_DEATHS}}/$MAX_DEATHS/g" "$SCRIPT_DIR/witches.md")
  run_agent "$EVAL_PROMPT" "Witches' Tea Party"

  # Handle crash
  if handle_crash "Witches' Tea Party"; then
    echo "Retrying after crash..."
    sleep 2
    continue
  fi

  # Check for completion/blocked signals from evaluation
  HAS_COMPLETE=false
  HAS_BLOCKED=false
  echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>" && HAS_COMPLETE=true
  echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>" && HAS_BLOCKED=true

  if $HAS_COMPLETE; then
    echo ""
    echo "Re:ZERO Loop complete! All stories passed."
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  if $HAS_BLOCKED; then
    echo ""
    echo "Re:ZERO Loop blocked. User intervention needed."
    echo "Blocked at iteration $i of $MAX_ITERATIONS"
    echo "Check $PROGRESS_FILE for details."
    exit 2
  fi

  # Evaluation complete (pass or fail handled within the session)
  DEATH_COUNT=0
  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Re:ZERO reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
