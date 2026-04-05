#!/usr/bin/env bash
# stop-process-queue.sh
# Stop hook — checks .doc-queue.json for pending doc tasks.
# If tasks exist, sends a systemMessage telling Claude to process them.

set -euo pipefail

QUEUE_FILE=".doc-queue.json"

# No queue file → nothing to do
if [ ! -f "$QUEUE_FILE" ]; then
  exit 0
fi

# Require jq
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Read and validate queue
QUEUE=$(cat "$QUEUE_FILE" 2>/dev/null) || exit 0
if ! printf '%s' "$QUEUE" | jq 'type == "array"' >/dev/null 2>&1; then
  exit 0
fi

# Check if queue has entries
TASK_COUNT=$(printf '%s' "$QUEUE" | jq 'length')
if [ "$TASK_COUNT" -eq 0 ]; then
  exit 0
fi

# Build a summary of pending tasks for the system message
TASK_SUMMARY=$(printf '%s' "$QUEUE" | jq -r '[.[] | .type] | group_by(.) | map("\(length) \(.[0])") | join(", ")')

# Output a JSON response with systemMessage instructing Claude to process the queue
cat <<ENDJSON
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "systemMessage": "doc-sync: There are ${TASK_COUNT} pending documentation tasks (${TASK_SUMMARY}) in .doc-queue.json. Use the doc-writer agent (subagent_type: \"doc-sync:doc-writer\") to process the queue. Pass the project root path and queue file path in the agent prompt. After processing, the agent will commit doc changes with a 'docs:' prefix and clear the queue."
  }
}
ENDJSON
