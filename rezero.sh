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

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Re:ZERO Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "==============================================================="

  # Inject MAX_DEATHS into prompt template
  PROMPT=$(sed "s/{{MAX_DEATHS}}/$MAX_DEATHS/g" "$SCRIPT_DIR/subaru.md")

  # Run the selected tool with the prompt, capturing exit code
  EXIT_CODE=0
  if [[ "$TOOL" == "codex" ]]; then
    # Use JSONL to show real-time progress (tool calls + text output)
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
    # Use stream-json to show real-time progress (tool calls + text output)
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

  # Detect agent crash: non-zero exit code without a recognized promise signal
  HAS_COMPLETE=false
  HAS_BLOCKED=false
  echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>" && HAS_COMPLETE=true
  echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>" && HAS_BLOCKED=true

  if [[ $EXIT_CODE -ne 0 ]] && ! $HAS_COMPLETE && ! $HAS_BLOCKED; then
    DEATH_COUNT=$((DEATH_COUNT + 1))
    echo ""
    echo "WARNING: Agent crashed with exit code $EXIT_CODE (death $DEATH_COUNT/$MAX_DEATHS)"
    echo "---" >> "$PROGRESS_FILE"
    echo "CRASH at iteration $i: Agent exited with code $EXIT_CODE (death $DEATH_COUNT/$MAX_DEATHS)" >> "$PROGRESS_FILE"
    echo "Time: $(date)" >> "$PROGRESS_FILE"

    if [[ $DEATH_COUNT -ge $MAX_DEATHS ]]; then
      echo ""
      echo "Re:ZERO Loop aborted: Agent crashed $DEATH_COUNT times (max deaths: $MAX_DEATHS)."
      echo "Check $PROGRESS_FILE for details."
      echo "ABORTED: Reached max deaths ($MAX_DEATHS) at iteration $i" >> "$PROGRESS_FILE"
      exit 3
    fi

    echo "Retrying after crash..."
    sleep 2
    continue
  fi

  # Check for completion signal
  if $HAS_COMPLETE; then
    echo ""
    echo "Re:ZERO Loop complete! All stories passed."
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  # Check for blocked signal
  if $HAS_BLOCKED; then
    echo ""
    echo "Re:ZERO Loop blocked. User intervention needed."
    echo "Blocked at iteration $i of $MAX_ITERATIONS"
    echo "Check $PROGRESS_FILE for details."
    exit 2
  fi

  # Agent exited successfully but without a promise signal — normal iteration
  DEATH_COUNT=0  # Reset on successful iteration
  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Re:ZERO reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
