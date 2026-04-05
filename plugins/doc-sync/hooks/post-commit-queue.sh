#!/usr/bin/env bash
# post-commit-queue.sh
# PostToolUse hook for Bash — detects git commits and queues doc tasks.
# Must complete in <2s. Only detects and queues — never writes docs.
# Reads detection rules from .doc-sync.json. Falls back to changelog-only without config/jq.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Fast pre-filter: skip if this isn't a git commit
if ! printf '%s\n' "$INPUT" | grep -q 'git commit'; then
  exit 0
fi

# Check for jq
HAS_JQ=false
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=true
fi

# Extract the command that was executed (needs jq)
if [ "$HAS_JQ" = true ]; then
  COMMAND=$(jq -r '.tool_input.command // empty' <<< "$INPUT")
  if ! printf '%s\n' "$COMMAND" | grep -qE 'git commit'; then
    exit 0
  fi
fi

# Get the commit details
COMMIT_MSG=$(git log -1 --format="%s" 2>/dev/null) || exit 0
COMMIT_HASH=$(git log -1 --format="%H" 2>/dev/null) || exit 0
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# Skip docs-only commits (prevent feedback loops)
if printf '%s\n' "$COMMIT_MSG" | grep -qE '^docs(\(.+\))?:'; then
  exit 0
fi

# Get changed files from the commit (use diff-tree to handle initial commits)
if git rev-parse HEAD~1 >/dev/null 2>&1; then
  CHANGED_FILES=$(git diff HEAD~1 --name-only 2>/dev/null) || exit 0
else
  CHANGED_FILES=$(git diff-tree --no-commit-id -r HEAD --name-only 2>/dev/null) || exit 0
fi

if [ -z "$CHANGED_FILES" ]; then
  exit 0
fi

CONFIG_FILE=".doc-sync.json"
QUEUE_FILE=".doc-queue.json"

# Without jq or without config: fall back to changelog-only detection
if [ "$HAS_JQ" != true ] || [ ! -f "$CONFIG_FILE" ]; then
  if printf '%s\n' "$COMMIT_MSG" | grep -qE '^(feat|fix|refactor|perf|security|revert)(\(.+\))?(!)?:'; then
    if [ "$HAS_JQ" = true ]; then
      ALL_FILES_JSON=$(printf '%s\n' "$CHANGED_FILES" | jq -R . | jq -s .)
      TASK=$(jq -n --arg commit "$COMMIT_HASH" \
        --arg msg "$COMMIT_MSG" \
        --arg ts "$TIMESTAMP" \
        --argjson files "$ALL_FILES_JSON" \
        '[{type: "changelog", commit: $commit, message: $msg, files: $files, timestamp: $ts}]')
      if [ -f "$QUEUE_FILE" ]; then
        EXISTING=$(cat "$QUEUE_FILE" 2>/dev/null) || EXISTING="[]"
        if ! printf '%s' "$EXISTING" | jq 'type == "array"' >/dev/null 2>&1; then
          EXISTING="[]"
        fi
      else
        EXISTING="[]"
      fi
      MERGED=$(jq -s '.[0] + .[1]' <<< "$EXISTING"$'\n'"$TASK")
      printf '%s\n' "$MERGED" | jq '.' > "$QUEUE_FILE"
    fi
  fi
  exit 0
fi

# --- Config-driven detection ---

CONFIG=$(cat "$CONFIG_FILE")

# Helper: check if a doc type is enabled in config
is_enabled() {
  local doc_type="$1"
  printf '%s' "$CONFIG" | jq -e --arg t "$doc_type" '.docs[$t].enabled == true' >/dev/null 2>&1
}

# Helper: get paths array for a doc type
get_paths() {
  local doc_type="$1"
  printf '%s' "$CONFIG" | jq -r --arg t "$doc_type" '.docs[$t].paths // [] | .[]' 2>/dev/null
}

# Helper: get patterns array for a doc type
get_patterns() {
  local doc_type="$1"
  printf '%s' "$CONFIG" | jq -r --arg t "$doc_type" '.docs[$t].patterns // [] | .[]' 2>/dev/null
}

# Helper: match changed files against glob patterns
match_files_by_path() {
  local doc_type="$1"
  local matched=""
  while IFS= read -r glob_pattern; do
    [ -z "$glob_pattern" ] && continue
    while IFS= read -r file; do
      local regex_pattern
      regex_pattern=$(printf '%s' "$glob_pattern" | sed 's/\./\\./g; s/\*\*/DOUBLESTAR/g; s/\*/[^/]*/g; s/DOUBLESTAR/.*/g; s/\?/./g')
      if printf '%s\n' "$file" | grep -qE "^${regex_pattern}$"; then
        matched="${matched}${file}"$'\n'
      fi
    done <<< "$CHANGED_FILES"
  done < <(get_paths "$doc_type")
  printf '%s' "$matched" | grep -v '^$' | sort -u || true
}

# Helper: match changed files by content patterns
match_files_by_content() {
  local doc_type="$1"
  local matched=""
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    while IFS= read -r file; do
      if [ -f "$file" ] && grep -qlE "$pattern" "$file" 2>/dev/null; then
        matched="${matched}${file}"$'\n'
      fi
    done <<< "$CHANGED_FILES"
  done < <(get_patterns "$doc_type")
  printf '%s' "$matched" | grep -v '^$' | sort -u || true
}

# Build task list
TASKS="[]"

# Helper: add a task to the list
add_task() {
  local task_type="$1"
  local files_json="$2"
  TASKS=$(printf '%s' "$TASKS" | jq --arg commit "$COMMIT_HASH" \
    --arg msg "$COMMIT_MSG" \
    --arg ts "$TIMESTAMP" \
    --arg type "$task_type" \
    --argjson files "$files_json" \
    '. + [{type: $type, commit: $commit, message: $msg, files: $files, timestamp: $ts}]')
}

# Helper: detect files by path with content pattern fallback, then add task
detect_and_queue() {
  local doc_type="$1"
  if ! is_enabled "$doc_type"; then return; fi
  local matched
  matched=$(match_files_by_path "$doc_type")
  if [ -z "$matched" ]; then
    matched=$(match_files_by_content "$doc_type")
  fi
  if [ -n "$matched" ]; then
    local json
    json=$(printf '%s\n' "$matched" | jq -R . | jq -s .)
    add_task "$doc_type" "$json"
  fi
}

# --- Path-matching types (with content pattern fallback) ---
if is_enabled "api-reference"; then
  SRC_FILES=$(match_files_by_path "api-reference")
  if [ -n "$SRC_FILES" ]; then
    FILES_JSON=$(printf '%s\n' "$SRC_FILES" | jq -R . | jq -s .)
    add_task "api-reference" "$FILES_JSON"
  fi
fi

detect_and_queue "agent-schemas"

# --- changelog: commit-message based ---
if is_enabled "changelog"; then
  if printf '%s\n' "$COMMIT_MSG" | grep -qE '^(feat|fix|refactor|perf|security|revert)(\(.+\))?(!)?:'; then
    ALL_FILES_JSON=$(printf '%s\n' "$CHANGED_FILES" | jq -R . | jq -s .)
    add_task "changelog" "$ALL_FILES_JSON"
  fi
fi

# --- architecture: structural heuristic ---
if is_enabled "architecture"; then
  if git rev-parse HEAD~1 >/dev/null 2>&1; then
    NEW_DIRS=$(git diff HEAD~1 --diff-filter=A --name-only 2>/dev/null | cut -d/ -f1 | sort -u | wc -l)
  else
    NEW_DIRS=$(git diff-tree --no-commit-id -r HEAD --diff-filter=A --name-only 2>/dev/null | cut -d/ -f1 | sort -u | wc -l)
  fi
  if [ "$NEW_DIRS" -gt 5 ]; then
    ALL_FILES_JSON=$(printf '%s\n' "$CHANGED_FILES" | jq -R . | jq -s .)
    add_task "architecture" "$ALL_FILES_JSON"
  fi
fi

# --- index: match doc file changes by configured paths ---
if is_enabled "index"; then
  DOC_FILES=$(match_files_by_path "index")
  if [ -n "$DOC_FILES" ]; then
    DOC_FILES_JSON=$(printf '%s\n' "$DOC_FILES" | jq -R . | jq -s .)
    add_task "index" "$DOC_FILES_JSON"
  fi
fi

detect_and_queue "api-contract"
detect_and_queue "env-config"

# If no tasks were generated, exit
TASK_COUNT=$(printf '%s' "$TASKS" | jq 'length')
if [ "$TASK_COUNT" -eq 0 ]; then
  exit 0
fi

# Append to existing queue (or create new one)
if [ -f "$QUEUE_FILE" ]; then
  EXISTING=$(cat "$QUEUE_FILE" 2>/dev/null) || EXISTING="[]"
  if ! printf '%s' "$EXISTING" | jq 'type == "array"' >/dev/null 2>&1; then
    EXISTING="[]"
  fi
else
  EXISTING="[]"
fi

# Merge existing and new tasks
MERGED=$(jq -s '.[0] + .[1]' <<< "$EXISTING"$'\n'"$TASKS")
printf '%s\n' "$MERGED" | jq '.' > "$QUEUE_FILE"

exit 0
