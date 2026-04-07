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
DEATH_LOG_FILE="$SCRIPT_DIR/death_returns.md"
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
    [ -f "$DEATH_LOG_FILE" ] && cp "$DEATH_LOG_FILE" "$ARCHIVE_FOLDER/"
    echo "  Archived to: $ARCHIVE_FOLDER"

    # Reset progress file for new run
    echo "# Re:ZERO Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"

    # Reset death return log for new run
    echo "# Death Return Log" > "$DEATH_LOG_FILE"
    echo "Started: $(date)" >> "$DEATH_LOG_FILE"
    echo "---" >> "$DEATH_LOG_FILE"
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

# Initialize death return log if it doesn't exist
if [ ! -f "$DEATH_LOG_FILE" ]; then
  echo "# Death Return Log" > "$DEATH_LOG_FILE"
  echo "Started: $(date)" >> "$DEATH_LOG_FILE"
  echo "---" >> "$DEATH_LOG_FILE"
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
PROMPTS_DIR="$SCRIPT_DIR/prompts"
WITCHES_DIR="$PROMPTS_DIR/witches"
WITCH_NAMES=("echidna" "minerva" "sekhmet" "typhon" "daphne" "carmilla")
WITCH_LABELS=("Echidna" "Minerva" "Sekhmet" "Typhon" "Daphne" "Carmilla")
WITCH_DOMAINS=("Completeness" "Regression" "Efficiency" "Integrity" "Resources" "Alignment")

# ── Helper: run agent, write output to file ─────────────────────────
# Usage: run_agent_to_file <prompt> <output_file>
# Exit code is written to <output_file>.exit
run_agent_to_file() {
  local PROMPT="$1"
  local OUT_FILE="$2"
  local MY_EXIT=0
  if [[ "$TOOL" == "codex" ]]; then
    local SFILE=$(mktemp)
    {
      echo "$PROMPT" | codex exec --full-auto --json - 2>/dev/null | \
        tee "$SFILE" | \
        jq --unbuffered -r '
          if .type == "item.completed" then
            if .item.type == "agent_message" then .item.text
            else "  \u25b6 \(.item.name // .item.type)"
            end
          else empty end
        ' >&2
    } || MY_EXIT=$?
    jq -rs '[.[] | select(.type == "item.completed" and .item.type == "agent_message") | .item.text] | join("\n")' "$SFILE" 2>/dev/null > "$OUT_FILE" || echo "" > "$OUT_FILE"
    rm -f "$SFILE"
  else
    local SFILE=$(mktemp)
    {
      echo "$PROMPT" | claude --dangerously-skip-permissions --print --verbose \
        --output-format stream-json 2>/dev/null | \
        tee "$SFILE" | \
        jq --unbuffered -r '
          if .type == "assistant" then
            [.message.content[]? |
              if .type == "tool_use" then "  \u25b6 \(.name)"
              elif .type == "text" then .text
              else empty end
            ] | join("\n") | select(length > 0)
          else empty end
        ' >&2
    } || MY_EXIT=$?
    jq -r 'select(.type == "result") | .result // empty' "$SFILE" 2>/dev/null > "$OUT_FILE" || echo "" > "$OUT_FILE"
    rm -f "$SFILE"
  fi
  echo "$MY_EXIT" > "${OUT_FILE}.exit"
}

# ── Helper: run agent, set $OUTPUT and $EXIT_CODE ───────────────────
run_agent() {
  local PROMPT="$1"
  local TMP=$(mktemp)
  run_agent_to_file "$PROMPT" "$TMP"
  OUTPUT=$(cat "$TMP")
  EXIT_CODE=$(cat "${TMP}.exit")
  rm -f "$TMP" "${TMP}.exit"
}

# ── Helper: check for crash ─────────────────────────────────────────
# Usage: handle_crash <label> <output_text> <exit_code>
# Returns 0 if crash detected and handled, 1 otherwise
handle_crash() {
  local LABEL="$1"
  local OUT_TEXT="$2"
  local EC="$3"
  local HC=false HB=false HI=false HM=false
  echo "$OUT_TEXT" | grep -q "<promise>COMPLETE</promise>" && HC=true
  echo "$OUT_TEXT" | grep -q "<promise>BLOCKED</promise>" && HB=true
  echo "$OUT_TEXT" | grep -q "<promise>IMPLEMENTED</promise>" && HI=true
  echo "$OUT_TEXT" | grep -q "<promise>COMMITTED</promise>" && HM=true

  if [[ $EC -ne 0 ]] && ! $HC && ! $HB && ! $HI && ! $HM; then
    DEATH_COUNT=$((DEATH_COUNT + 1))
    echo ""
    echo "WARNING: $LABEL crashed with exit code $EC (death $DEATH_COUNT/$MAX_DEATHS)"
    echo "---" >> "$PROGRESS_FILE"
    echo "CRASH at iteration $i ($LABEL): Agent exited with code $EC (death $DEATH_COUNT/$MAX_DEATHS)" >> "$PROGRESS_FILE"
    echo "Story: ${CURRENT_STORY_ID:-unknown} — ${CURRENT_STORY_TITLE:-unknown}" >> "$PROGRESS_FILE"
    echo "Time: $(date)" >> "$PROGRESS_FILE"

    echo "" >> "$DEATH_LOG_FILE"
    echo "## $(date) - CRASH at iteration $i" >> "$DEATH_LOG_FILE"
    echo "**Type**: Agent Crash" >> "$DEATH_LOG_FILE"
    echo "**Story**: ${CURRENT_STORY_ID:-unknown} — ${CURRENT_STORY_TITLE:-unknown}" >> "$DEATH_LOG_FILE"
    echo "**Phase**: $LABEL" >> "$DEATH_LOG_FILE"
    echo "**Exit Code**: $EC" >> "$DEATH_LOG_FILE"
    echo "**Death Count**: $DEATH_COUNT / $MAX_DEATHS" >> "$DEATH_LOG_FILE"

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

# ── Helper: parse witch output ──────────────────────────────────────
# Usage: parse_witch_field <output_text> <field>  (field: VERDICT, ASSESSMENT, ISSUES)
parse_witch_field() {
  local OUT_TEXT="$1"
  local FIELD="$2"
  echo "$OUT_TEXT" | grep "^\[${FIELD}\]" | tail -1 | sed "s/^\[${FIELD}\] //"
}

# ── Helper: print evaluation table ──────────────────────────────────
print_evaluation_table() {
  local VERDICTS=("$@")
  # VERDICTS array: [verdict0, assessment0, issues0, verdict1, assessment1, issues1, ...]

  echo ""
  printf "┌───────────┬──────────────┬─────────┬────────────────────────────────────────────────────┬──────────────────────────────────────┐\n"
  printf "│ Evaluator │ Domain       │ Verdict │ Assessment                                         │ Issues                               │\n"
  printf "├───────────┼──────────────┼─────────┼────────────────────────────────────────────────────┼──────────────────────────────────────┤\n"

  for idx in 0 1 2 3 4 5; do
    local V_IDX=$((idx * 3))
    local A_IDX=$((idx * 3 + 1))
    local I_IDX=$((idx * 3 + 2))
    local VERDICT="${VERDICTS[$V_IDX]}"
    local ASSESSMENT="${VERDICTS[$A_IDX]}"
    local ISSUES="${VERDICTS[$I_IDX]}"
    local LABEL="${WITCH_LABELS[$idx]}"
    local DOMAIN="${WITCH_DOMAINS[$idx]}"

    # Color the verdict
    local COLOR=""
    local RESET="\033[0m"
    case "$VERDICT" in
      PASS) COLOR="\033[32m" ;;
      WARN) COLOR="\033[33m" ;;
      FAIL) COLOR="\033[31m" ;;
    esac

    # Truncate long text for table display
    local ASSESS_TRUNC="${ASSESSMENT:0:50}"
    local ISSUES_TRUNC="${ISSUES:0:36}"

    printf "│ %-9s │ %-12s │ ${COLOR}%-7s${RESET} │ %-50s │ %-36s │\n" \
      "$LABEL" "$DOMAIN" "$VERDICT" "$ASSESS_TRUNC" "$ISSUES_TRUNC"
  done

  printf "└───────────┴──────────────┴─────────┴────────────────────────────────────────────────────┴──────────────────────────────────────┘\n"
}

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Re:ZERO Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "==============================================================="

  # Extract current story ID and title from task.json for crash logging
  CURRENT_STORY_ID=$(jq -r '[.stories[] | select(.passes == false)] | sort_by(.priority) | .[0].id // "unknown"' "$TASK_FILE" 2>/dev/null || echo "unknown")
  CURRENT_STORY_TITLE=$(jq -r '[.stories[] | select(.passes == false)] | sort_by(.priority) | .[0].title // "unknown"' "$TASK_FILE" 2>/dev/null || echo "unknown")

  # ── Phase 1: Implementation (Subaru) ──────────────────────────────
  echo ""
  echo "  Phase 1: Implementation"
  echo "  ───────────────────────"

  IMPL_PROMPT=$(sed "s/{{MAX_DEATHS}}/$MAX_DEATHS/g" "$PROMPTS_DIR/subaru.md")
  run_agent "$IMPL_PROMPT"

  # Handle crash
  if handle_crash "Implementation" "$OUTPUT" "$EXIT_CODE"; then
    echo "Retrying after crash..."
    sleep 2
    continue
  fi

  # Check for signals
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

  if ! $HAS_IMPLEMENTED; then
    DEATH_COUNT=0
    echo "Implementation aborted early. Continuing to next iteration..."
    sleep 2
    continue
  fi

  # ── Phase 2: Witches' Tea Party (6 parallel sessions) ─────────────
  echo ""
  echo "  Phase 2: Witches' Tea Party"
  echo "  ─────────────────────────────────────────────"
  echo "  Launching 6 witch evaluators in parallel..."

  WITCH_TMP=$(mktemp -d)
  WITCH_PIDS=()

  for idx in 0 1 2 3 4 5; do
    WITCH_NAME="${WITCH_NAMES[$idx]}"
    WITCH_PROMPT=$(cat "$WITCHES_DIR/${WITCH_NAME}.md")
    echo "    ▸ ${WITCH_LABELS[$idx]} (${WITCH_DOMAINS[$idx]})"
    run_agent_to_file "$WITCH_PROMPT" "$WITCH_TMP/$WITCH_NAME" &
    WITCH_PIDS+=($!)
  done

  # Wait for all witches to complete
  echo ""
  echo "  Waiting for all evaluators to finish..."
  WITCH_CRASH=false
  for pid in "${WITCH_PIDS[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  # ── Collect and parse results ─────────────────────────────────────
  ALL_VERDICTS=()
  FINAL_VERDICT="PASS"
  HAS_WARN=false
  EVALUATION_RESULTS=""

  for idx in 0 1 2 3 4 5; do
    WITCH_NAME="${WITCH_NAMES[$idx]}"
    WITCH_OUTPUT=""
    WITCH_EC=0

    if [ -f "$WITCH_TMP/$WITCH_NAME" ]; then
      WITCH_OUTPUT=$(cat "$WITCH_TMP/$WITCH_NAME")
    fi
    if [ -f "$WITCH_TMP/${WITCH_NAME}.exit" ]; then
      WITCH_EC=$(cat "$WITCH_TMP/${WITCH_NAME}.exit")
    fi

    # Check for crash
    if [[ $WITCH_EC -ne 0 ]] && [ -z "$WITCH_OUTPUT" ]; then
      echo "  WARNING: ${WITCH_LABELS[$idx]} crashed (exit code $WITCH_EC)"
      ALL_VERDICTS+=("FAIL" "${WITCH_LABELS[$idx]} session crashed with exit code $WITCH_EC" "Session crash")
      FINAL_VERDICT="FAIL"
      EVALUATION_RESULTS+="### ${WITCH_LABELS[$idx]} — ${WITCH_DOMAINS[$idx]}"$'\n'
      EVALUATION_RESULTS+="**Verdict**: FAIL (session crashed)"$'\n\n'
      continue
    fi

    # Parse verdict
    VERDICT=$(parse_witch_field "$WITCH_OUTPUT" "VERDICT")
    ASSESSMENT=$(parse_witch_field "$WITCH_OUTPUT" "ASSESSMENT")
    ISSUES=$(parse_witch_field "$WITCH_OUTPUT" "ISSUES")

    # Default to FAIL if verdict not parseable
    if [[ "$VERDICT" != "PASS" && "$VERDICT" != "WARN" && "$VERDICT" != "FAIL" ]]; then
      VERDICT="FAIL"
      ASSESSMENT="${ASSESSMENT:-Could not parse evaluation output}"
      ISSUES="${ISSUES:-Unparseable output}"
    fi

    ALL_VERDICTS+=("$VERDICT" "$ASSESSMENT" "$ISSUES")

    if [[ "$VERDICT" == "FAIL" ]]; then
      FINAL_VERDICT="FAIL"
    elif [[ "$VERDICT" == "WARN" && "$FINAL_VERDICT" != "FAIL" ]]; then
      HAS_WARN=true
    fi

    EVALUATION_RESULTS+="### ${WITCH_LABELS[$idx]} — ${WITCH_DOMAINS[$idx]}"$'\n'
    EVALUATION_RESULTS+="**Verdict**: $VERDICT"$'\n'
    EVALUATION_RESULTS+="**Assessment**: $ASSESSMENT"$'\n'
    EVALUATION_RESULTS+="**Issues**: $ISSUES"$'\n\n'
  done

  rm -rf "$WITCH_TMP"

  # Determine final verdict
  if [[ "$FINAL_VERDICT" != "FAIL" && "$HAS_WARN" == "true" ]]; then
    FINAL_VERDICT="WARN"
  fi

  # Print the combined evaluation table
  print_evaluation_table "${ALL_VERDICTS[@]}"

  # Print final verdict with color
  echo ""
  case "$FINAL_VERDICT" in
    PASS) printf "  Final Verdict: \033[32mPASS\033[0m\n" ;;
    WARN) printf "  Final Verdict: \033[33mPASS (with warnings)\033[0m\n" ;;
    FAIL) printf "  Final Verdict: \033[31mFAIL\033[0m\n" ;;
  esac

  # ── Helper: inject evaluation results into a prompt template ──────
  inject_evaluation() {
    local TMPL="$1"
    TMPL=$(echo "$TMPL" | sed "s/{{MAX_DEATHS}}/$MAX_DEATHS/g")
    TMPL=$(echo "$TMPL" | sed "s/{{FINAL_VERDICT}}/$FINAL_VERDICT/g")
    local EVAL_RESULTS="$EVALUATION_RESULTS"
    TMPL="${TMPL//\{\{EVALUATION_RESULTS\}\}/$EVAL_RESULTS}"
    echo "$TMPL"
  }

  # ── Phase 3: Rem (Technical Debt Recording) ──────────────────────
  # Rem runs BEFORE Satella so debt entries are included in the commit.
  # Only runs on PASS/WARN — on FAIL, Satella reverts everything.
  if [[ "$FINAL_VERDICT" != "FAIL" ]]; then
    echo ""
    echo "  Phase 3: Rem — Technical Debt Recording"
    echo "  ─────────────────────────────────────────"

    REM_PROMPT=$(inject_evaluation "$(cat "$PROMPTS_DIR/rem.md")")
    run_agent "$REM_PROMPT"

    # Handle crash (non-fatal — debt tracking is best-effort)
    if handle_crash "Rem" "$OUTPUT" "$EXIT_CODE"; then
      echo "Rem session crashed. Continuing to Satella..."
      sleep 2
    fi
  fi

  # ── Phase 4: Satella (Judgment & Checkpoint) ──────────────────────
  echo ""
  echo "  Phase 4: Satella — Final Judgment"
  echo "  ─────────────────────────────────"

  SATELLA_PROMPT=$(inject_evaluation "$(cat "$WITCHES_DIR/satella.md")")
  run_agent "$SATELLA_PROMPT"

  # Handle crash
  if handle_crash "Satella" "$OUTPUT" "$EXIT_CODE"; then
    echo "Retrying after crash..."
    sleep 2
    continue
  fi

  # Check for signals
  HAS_COMMITTED=false
  HAS_BLOCKED=false
  HAS_COMPLETE=false
  echo "$OUTPUT" | grep -q "<promise>COMMITTED</promise>" && HAS_COMMITTED=true
  echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>" && HAS_BLOCKED=true
  echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>" && HAS_COMPLETE=true

  if $HAS_BLOCKED; then
    echo ""
    echo "Re:ZERO Loop blocked. User intervention needed."
    echo "Blocked at iteration $i of $MAX_ITERATIONS"
    echo "Check $PROGRESS_FILE for details."
    exit 2
  fi

  if $HAS_COMPLETE; then
    echo ""
    echo "Re:ZERO Loop complete! All stories passed."
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  # If not COMMITTED, this was a FAIL → revert happened
  if ! $HAS_COMMITTED; then
    DEATH_COUNT=0
    echo "Evaluation failed. Continuing to next iteration..."
    sleep 2
    continue
  fi

  # Iteration complete — checkpoint succeeded, reset death return log
  DEATH_COUNT=0
  echo "# Death Return Log" > "$DEATH_LOG_FILE"
  echo "Started: $(date)" >> "$DEATH_LOG_FILE"
  echo "---" >> "$DEATH_LOG_FILE"
  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Re:ZERO reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
