#!/bin/bash
# Leo Wiggum v2 - Autonomous AI coding loop
# Usage: leo-wiggum.sh [max_iterations] [--headed]
#
# Run from your project root directory.
# Requires: .leo/prd.json in current directory

set -e

MAX_ITERATIONS=${1:-15}
HEADED=""
if [[ "$2" == "--headed" ]] || [[ "$1" == "--headed" ]]; then
  HEADED="--headed"
  if [[ "$1" == "--headed" ]]; then
    MAX_ITERATIONS=${2:-15}
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
LEO_DIR="./.leo"
PRD_FILE="$LEO_DIR/prd.json"
MEMORY_FILE="$LEO_DIR/memory.json"
QUALITY_FILE="$LEO_DIR/quality-metrics.json"
SCREENSHOTS_DIR="$LEO_DIR/screenshots"
ARCHIVE_DIR="$LEO_DIR/archive"
LAST_BRANCH_FILE="$LEO_DIR/.last-branch"

# --- Preflight ---
if [ ! -f "$PRD_FILE" ]; then
  echo "Error: .leo/prd.json not found in current directory."
  echo ""
  echo "To get started, ask Claude Code to run the leo-wiggum skill:"
  echo "  'Use leo-wiggum to implement <your feature description>'"
  exit 1
fi

# Ensure screenshots directory exists
mkdir -p "$SCREENSHOTS_DIR"

# --- Archive previous run if branch changed ---
if [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    DATE=$(date +%Y-%m-%d)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^leo/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$MEMORY_FILE" ] && cp "$MEMORY_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$QUALITY_FILE" ] && cp "$QUALITY_FILE" "$ARCHIVE_FOLDER/"
    echo "  Archived to: $ARCHIVE_FOLDER"
  fi
fi

# Track current branch
CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
if [ -n "$CURRENT_BRANCH" ]; then
  echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
fi

# --- Progress reporting ---
print_progress() {
  local total=$(jq '.stories | length' "$PRD_FILE" 2>/dev/null || echo "0")
  local passed=$(jq '[.stories[] | select(.status == "passed")] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  local failed=$(jq '[.stories[] | select(.status == "failed")] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  local skipped=$(jq '[.stories[] | select(.status == "skipped")] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  local in_progress=$(jq '[.stories[] | select(.status == "in-progress")] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  local pending=$(jq '[.stories[] | select(.status == "pending")] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  local current_phase=$(jq -r '[.phases[] | select(.status != "complete")][0].name // "All Complete"' "$PRD_FILE" 2>/dev/null || echo "Unknown")

  echo "Phase: $current_phase | $passed passed, $failed failed, $skipped skipped, $pending pending (of $total)"
}

# --- Main loop ---
echo ""
echo "=== Leo Wiggum v2 ==="
echo "Max iterations: $MAX_ITERATIONS"
echo "Branch: $CURRENT_BRANCH"
print_progress
echo ""

CONSECUTIVE_BLOCKED=0
MAX_CONSECUTIVE_BLOCKED=3

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "================================================================"
  echo "  Iteration $i of $MAX_ITERATIONS"
  echo "================================================================"
  print_progress
  echo ""

  # Build iteration prompt from the iteration agent prompt
  PROMPT_FILE="$SKILL_DIR/prompts/iteration-agent.md"
  if [ ! -f "$PROMPT_FILE" ]; then
    # Fallback to prompt.md if prompts/ directory doesn't exist
    PROMPT_FILE="$SKILL_DIR/prompt.md"
  fi

  OUTPUT=$(cat "$PROMPT_FILE" | claude --dangerously-skip-permissions --print 2>&1 | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "=== ALL STORIES COMPLETE ==="
    print_progress
    exit 0
  fi

  # Check for blocked signal
  if echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>"; then
    CONSECUTIVE_BLOCKED=$((CONSECUTIVE_BLOCKED + 1))
    echo ""
    echo "WARNING: All remaining stories blocked/skipped ($CONSECUTIVE_BLOCKED/$MAX_CONSECUTIVE_BLOCKED)"
    if [ $CONSECUTIVE_BLOCKED -ge $MAX_CONSECUTIVE_BLOCKED ]; then
      echo ""
      echo "=== HALTING: $MAX_CONSECUTIVE_BLOCKED consecutive blocked iterations ==="
      print_progress
      echo ""
      echo "Check .leo/prd.json for skipped/blocked stories."
      echo "Check .leo/memory.json for failure details."
      exit 1
    fi
  else
    CONSECUTIVE_BLOCKED=0
  fi

  # Quality ratchet sanity check (belt-and-suspenders)
  if [ -f "$QUALITY_FILE" ]; then
    SNAPSHOT_COUNT=$(jq '.snapshots | length' "$QUALITY_FILE" 2>/dev/null || echo "0")
    if [ "$SNAPSHOT_COUNT" -gt 0 ]; then
      BASELINE_TS=$(jq '.baseline.typescriptErrors // 0' "$QUALITY_FILE" 2>/dev/null || echo "0")
      LATEST_TS=$(jq '.snapshots[-1].typescriptErrors // 0' "$QUALITY_FILE" 2>/dev/null || echo "0")
      if [ "$LATEST_TS" -gt "$BASELINE_TS" ] 2>/dev/null; then
        echo "WARNING: Quality ratchet violation (TS errors: $BASELINE_TS -> $LATEST_TS)"
      fi
    fi
  fi

  echo ""
  echo "Iteration $i complete."
  sleep 2
done

echo ""
echo "=== Max iterations ($MAX_ITERATIONS) reached ==="
print_progress
echo ""
echo "Check .leo/prd.json for remaining stories."
exit 1
