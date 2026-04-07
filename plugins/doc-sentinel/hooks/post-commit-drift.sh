#!/usr/bin/env bash
# doc-sentinel: PostToolUse hook for Bash
# Detects git commits, finds docs referencing changed files, queues drift warnings.
# Must complete in <2s. Exits cleanly on all errors.

set -euo pipefail

# ─── Fast pre-filter ─────────────────────────────────────────────────────────
# Read the tool input from stdin. Skip if not a git commit.
INPUT=$(cat)
if ! printf '%s\n' "$INPUT" | grep -q 'git commit'; then
  exit 0
fi

# If jq is available, check the actual command (not just surrounding text)
if command -v jq &>/dev/null; then
  COMMAND=$(jq -r '.tool_input.command // empty' <<< "$INPUT")
  if ! printf '%s\n' "$COMMAND" | grep -qE 'git commit'; then
    exit 0
  fi
fi

# ─── Skip docs-only commits ──────────────────────────────────────────────────
COMMIT_MSG=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
if [ -z "$COMMIT_MSG" ]; then
  exit 0
fi

# Skip docs: prefix commits to avoid feedback loops
if printf '%s\n' "$COMMIT_MSG" | grep -qE '^docs(\(.+\))?:'; then
  exit 0
fi

# ─── Configuration ────────────────────────────────────────────────────────────
CONFIG_FILE=".doc-sentinel.json"
DRIFT_FILE=".doc-sentinel-drift.json"
DOC_ROOT="docs"
EXTRA_DOCS=""

if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
  DOC_ROOT=$(jq -r '.docs_root // "docs"' "$CONFIG_FILE")
  EXTRA_DOCS=$(jq -r '.watch_files // [] | .[]' "$CONFIG_FILE" 2>/dev/null || echo "")
fi

# ─── Get changed files from the last commit ──────────────────────────────────
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || echo "")
if [ -z "$CHANGED_FILES" ]; then
  exit 0
fi

# Filter to source files only (skip docs, configs, lockfiles)
SOURCE_FILES=$(echo "$CHANGED_FILES" | grep -vE '\.(md|txt|json|lock|yaml|yml|toml)$' | grep -vE '^(docs/|\.github/|\.vscode/)' || true)
if [ -z "$SOURCE_FILES" ]; then
  exit 0
fi

# Apply ignore_sources patterns from config
if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
  IGNORE_PATTERNS=$(jq -r '.ignore_sources // [] | .[]' "$CONFIG_FILE" 2>/dev/null || echo "")
  if [ -n "$IGNORE_PATTERNS" ]; then
    FILTERED=""
    while IFS= read -r src_file; do
      [ -z "$src_file" ] && continue
      SKIP=false
      while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        # Convert glob to regex: *.test.* → .*\.test\..*
        REGEX=$(printf '%s' "$pattern" | sed 's/\./\\./g; s/\*\*/DOUBLESTAR/g; s/\*/[^/]*/g; s/DOUBLESTAR/.*/g')
        if printf '%s\n' "$src_file" | grep -qE "(^|/)${REGEX}$"; then
          SKIP=true
          break
        fi
      done <<< "$IGNORE_PATTERNS"
      if [ "$SKIP" = false ]; then
        FILTERED=$(printf '%s\n%s' "$FILTERED" "$src_file")
      fi
    done <<< "$SOURCE_FILES"
    SOURCE_FILES=$(echo "$FILTERED" | sed '/^$/d')
    if [ -z "$SOURCE_FILES" ]; then
      exit 0
    fi
  fi
fi

# ─── Find docs that reference changed files ───────────────────────────────────
# Build a list of doc files to scan
DOC_FILES=""
if [ -d "$DOC_ROOT" ]; then
  DOC_FILES=$(find "$DOC_ROOT" -name '*.md' -type f 2>/dev/null || true)
fi

# Add top-level doc files
for f in AGENTS.md ARCHITECTURE.md CLAUDE.md README.md; do
  if [ -f "$f" ]; then
    DOC_FILES=$(printf '%s\n%s' "$DOC_FILES" "$f")
  fi
done

# Add extra watched files from config
if [ -n "$EXTRA_DOCS" ]; then
  while IFS= read -r extra; do
    if [ -f "$extra" ]; then
      DOC_FILES=$(printf '%s\n%s' "$DOC_FILES" "$extra")
    fi
  done <<< "$EXTRA_DOCS"
fi

if [ -z "$DOC_FILES" ]; then
  exit 0
fi

# ─── Cross-reference: which docs mention changed source files? ────────────────
DRIFT_WARNINGS=""
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

DOC_FILE_LIST=$(echo "$DOC_FILES" | sed '/^$/d' | sort -u)

while IFS= read -r src_file; do
  [ -z "$src_file" ] && continue

  # Generate search patterns from the file path
  # Match: full path, filename, or module name (without extension)
  BASENAME=$(basename "$src_file")
  MODULE_NAME="${BASENAME%.*}"

  # Search all doc files at once with grep -l (one process instead of N)
  MATCHING_DOCS=$(echo "$DOC_FILE_LIST" | xargs grep -lE "(${src_file}|${BASENAME}|${MODULE_NAME})" 2>/dev/null || true)
  MATCHING_DOCS=$(echo "$MATCHING_DOCS" | sed '/^$/d' | sort -u)
  if [ -n "$MATCHING_DOCS" ]; then
    while IFS= read -r doc; do
      [ -z "$doc" ] && continue
      # Build JSON warning entry (without jq for speed)
      DRIFT_WARNINGS=$(printf '%s{"source":"%s","doc":"%s","commit":"%s","message":"%s","timestamp":"%s"}\n' \
        "$DRIFT_WARNINGS" "$src_file" "$doc" "$COMMIT_HASH" "$COMMIT_MSG" "$TIMESTAMP")
    done <<< "$MATCHING_DOCS"
  fi
done <<< "$SOURCE_FILES"

if [ -z "$DRIFT_WARNINGS" ]; then
  exit 0
fi

# ─── Append to drift file ────────────────────────────────────────────────────
# Use jq if available for clean JSON, otherwise append raw
if command -v jq &>/dev/null; then
  # Build a JSON array from the warnings
  WARNINGS_JSON=$(echo "$DRIFT_WARNINGS" | sed '/^$/d' | jq -s '.')

  if [ -f "$DRIFT_FILE" ]; then
    EXISTING=$(jq '.' "$DRIFT_FILE" 2>/dev/null || echo "[]")
    echo "$EXISTING" | jq --argjson new "$WARNINGS_JSON" '. + $new' > "$DRIFT_FILE"
  else
    echo "$WARNINGS_JSON" > "$DRIFT_FILE"
  fi
else
  # Fallback: append line-delimited JSON
  echo "$DRIFT_WARNINGS" >> "$DRIFT_FILE"
fi

WARNING_COUNT=$(echo "$DRIFT_WARNINGS" | sed '/^$/d' | wc -l | tr -d ' ')
UNIQUE_DOCS=$(echo "$DRIFT_WARNINGS" | sed '/^$/d' | grep -oE '"doc":"[^"]*"' | sort -u | wc -l | tr -d ' ')

# Output status for the hook system
echo "doc-sentinel: ${WARNING_COUNT} drift warning(s) across ${UNIQUE_DOCS} doc(s) from commit ${COMMIT_HASH}"
