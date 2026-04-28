#!/usr/bin/env bash
# doc-sentinel: PostToolUse hook for Bash
# Detects git commits, finds docs referencing changed files, queues drift warnings.
# Must complete in <2s. Exits cleanly on all errors.

set -euo pipefail

# ─── Resolve project root ────────────────────────────────────────────────────
# Hooks may run from any subdirectory of the project. Always resolve paths
# relative to $CLAUDE_PROJECT_DIR (set by Claude Code), falling back to
# `git rev-parse` for environments that skipped the export.
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi
cd "$PROJECT_ROOT"

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

# ─── Helpers ─────────────────────────────────────────────────────────────────

# Escape ERE special characters so a path can be safely embedded in a regex.
# Without this, `qmd.ts` would also match `qmd_ts`, `qmdets`, etc., because
# the `.` was being interpreted as the any-char wildcard.
escape_regex() {
  printf '%s' "$1" | sed 's/[][\\^$.*+?(){}|]/\\&/g'
}

# Convert a glob pattern (e.g. `docs/decisions/**`, `*.test.*`) to an ERE
# regex anchored at end-of-string. The caller still has to anchor the start.
# `?` must be expanded before `**/` becomes `(.*/)?` so the regex `?`
# quantifier isn't clobbered by the glob `?` → `.` rule. Use `#` as sed
# delimiter — BSD sed (macOS) mis-parses `/` inside the replacement of
# `s/old/new/g`.
glob_to_regex() {
  printf '%s' "$1" | sed -e 's#\.#\\.#g' \
                          -e 's#?#.#g' \
                          -e 's#\*\*/#DBLSTARSLASH#g' \
                          -e 's#\*\*#.*#g' \
                          -e 's#\*#[^/]*#g' \
                          -e 's#DBLSTARSLASH#(.*/)?#g'
}

# Return 0 if `path` matches any of the newline-separated glob patterns in
# `patterns`, 1 otherwise.
matches_any_glob() {
  local path="$1"
  local patterns="$2"
  local pattern regex
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    regex=$(glob_to_regex "$pattern")
    if printf '%s\n' "$path" | grep -qE "(^|/)${regex}\$"; then
      return 0
    fi
  done <<< "$patterns"
  return 1
}

# ─── Configuration ────────────────────────────────────────────────────────────
CONFIG_FILE="$PROJECT_ROOT/.doc-sentinel.json"
DRIFT_FILE="$PROJECT_ROOT/.doc-sentinel-drift.json"
DOC_ROOT="$PROJECT_ROOT/docs"
EXTRA_DOCS=""
IGNORE_SOURCE_PATTERNS=""
IGNORE_DOC_PATTERNS=""

if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
  DOC_ROOT=$(jq -r '.docs_root // "docs"' "$CONFIG_FILE")
  EXTRA_DOCS=$(jq -r '.watch_files // [] | .[]' "$CONFIG_FILE" 2>/dev/null || echo "")
  IGNORE_SOURCE_PATTERNS=$(jq -r '.ignore_sources // [] | .[]' "$CONFIG_FILE" 2>/dev/null || echo "")
  IGNORE_DOC_PATTERNS=$(jq -r '.ignore_docs // [] | .[]' "$CONFIG_FILE" 2>/dev/null || echo "")
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
if [ -n "$IGNORE_SOURCE_PATTERNS" ]; then
  FILTERED=""
  while IFS= read -r src_file; do
    [ -z "$src_file" ] && continue
    if ! matches_any_glob "$src_file" "$IGNORE_SOURCE_PATTERNS"; then
      FILTERED=$(printf '%s\n%s' "$FILTERED" "$src_file")
    fi
  done <<< "$SOURCE_FILES"
  SOURCE_FILES=$(echo "$FILTERED" | sed '/^$/d')
  if [ -z "$SOURCE_FILES" ]; then
    exit 0
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
  if [ -f "$PROJECT_ROOT/$f" ]; then
    DOC_FILES=$(printf '%s\n%s' "$DOC_FILES" "$PROJECT_ROOT/$f")
  fi
done

# Add extra watched files from config
if [ -n "$EXTRA_DOCS" ]; then
  while IFS= read -r extra; do
    if [ -f "$PROJECT_ROOT/$extra" ]; then
      DOC_FILES=$(printf '%s\n%s' "$DOC_FILES" "$PROJECT_ROOT/$extra")
    fi
  done <<< "$EXTRA_DOCS"
fi

if [ -z "$DOC_FILES" ]; then
  exit 0
fi

DOC_FILE_LIST=$(echo "$DOC_FILES" | sed '/^$/d' | sort -u)

# Apply ignore_docs patterns from config. Matches against repo-relative paths
# so glob patterns like `docs/decisions/**` work the way users expect.
if [ -n "$IGNORE_DOC_PATTERNS" ]; then
  FILTERED=""
  while IFS= read -r doc_file; do
    [ -z "$doc_file" ] && continue
    REL_PATH="${doc_file#$PROJECT_ROOT/}"
    if ! matches_any_glob "$REL_PATH" "$IGNORE_DOC_PATTERNS"; then
      FILTERED=$(printf '%s\n%s' "$FILTERED" "$doc_file")
    fi
  done <<< "$DOC_FILE_LIST"
  DOC_FILE_LIST=$(echo "$FILTERED" | sed '/^$/d')
  if [ -z "$DOC_FILE_LIST" ]; then
    exit 0
  fi
fi

# ─── Cross-reference: which docs mention changed source files? ────────────────
DRIFT_WARNINGS=""
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

while IFS= read -r src_file; do
  [ -z "$src_file" ] && continue

  # Generate search patterns from the file path. Match three forms, from
  # tightest to loosest:
  #
  #   1. The full path                 — `packages/agents/src/lib/qmd.ts`
  #   2. The bare basename             — `qmd.ts`
  #   3. The backtick-wrapped module   — `` `qmd` ``
  #
  # The backtick gate on the module name is the key noise control: without
  # it, every commit touching `models.ts` or `queue.ts` would flag any doc
  # that mentioned the words "models" or "queue" in prose (e.g., an ADR
  # title or a paragraph about Redis queues), and the signal-to-noise
  # ratio collapses. The plugin's `doc-references` rule already encourages
  # backtick-quoted code identifiers, so this matcher meets docs at that
  # convention.
  #
  # All three patterns get regex-escaped before being interpolated so that
  # path separators and dots are treated as literals.
  BASENAME=$(basename "$src_file")
  MODULE_NAME="${BASENAME%.*}"
  SRC_FILE_RE=$(escape_regex "$src_file")
  BASENAME_RE=$(escape_regex "$BASENAME")
  MODULE_NAME_RE=$(escape_regex "$MODULE_NAME")

  # Search all doc files at once with grep -l (one process instead of N)
  MATCHING_DOCS=$(echo "$DOC_FILE_LIST" | xargs grep -lE "(${SRC_FILE_RE}|${BASENAME_RE}|\`${MODULE_NAME_RE}\`)" 2>/dev/null || true)
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
