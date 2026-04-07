#!/usr/bin/env bash
# doc-sentinel: Stop hook
# Checks for accumulated drift warnings and prompts resolution.
# Exits cleanly on all errors.

set -euo pipefail

DRIFT_FILE=".doc-sentinel-drift.json"

# No drift file — nothing to do
if [ ! -f "$DRIFT_FILE" ]; then
  exit 0
fi

# Check for jq
if ! command -v jq &>/dev/null; then
  # Fallback: count lines
  WARNING_COUNT=$(wc -l < "$DRIFT_FILE" | tr -d ' ')
  if [ "$WARNING_COUNT" -eq 0 ]; then
    exit 0
  fi

  cat <<RESP
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "systemMessage": "doc-sentinel: ${WARNING_COUNT} documentation drift warning(s) detected during this session. Run /doc-sentinel:resolve to review and fix affected docs, or /doc-sentinel:scan for a full drift report."
  }
}
RESP
  exit 0
fi

# Parse with jq
WARNING_COUNT=$(jq 'length' "$DRIFT_FILE" 2>/dev/null || echo "0")
if [ "$WARNING_COUNT" -eq 0 ] || [ "$WARNING_COUNT" = "null" ]; then
  exit 0
fi

# Build summary
UNIQUE_DOCS=$(jq -r '[.[].doc] | unique | length' "$DRIFT_FILE" 2>/dev/null || echo "?")
UNIQUE_SOURCES=$(jq -r '[.[].source] | unique | length' "$DRIFT_FILE" 2>/dev/null || echo "?")
DOC_LIST=$(jq -r '[.[].doc] | unique | join(", ")' "$DRIFT_FILE" 2>/dev/null || echo "")

cat <<RESP
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "systemMessage": "doc-sentinel: ${WARNING_COUNT} drift warning(s) accumulated during this session — ${UNIQUE_SOURCES} source file(s) changed that are referenced in ${UNIQUE_DOCS} doc(s): ${DOC_LIST}. Run /doc-sentinel:resolve to review each warning and fix affected documentation, or dismiss false positives."
  }
}
RESP
