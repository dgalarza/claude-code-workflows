#!/usr/bin/env bash
# doc-sentinel: Stop hook
#
# Blocks the model from stopping when drift warnings are accumulated and
# instructs it to dispatch the drift-resolver subagent. A session-id marker
# ensures we block at most once per session, so a subagent that can't fully
# clear the drift file can't trap the model in an infinite loop.
#
# Why `decision: block` and not `systemMessage`:
#   Stop-hook systemMessage is displayed to the user in the UI but is NOT
#   auto-injected into the model's next-turn context, so it can't actually
#   trigger autonomous behavior. `decision: "block"` with a `reason` is the
#   only mechanism that forces the model to respond to the hook.
#
# Exits cleanly on all errors — never blocks on plumbing failures.

set -euo pipefail

# ─── Resolve project root ────────────────────────────────────────────────────
# Hooks can run from any subdirectory of the project. Always prefer
# $CLAUDE_PROJECT_DIR (exported by Claude Code) with a git fallback.
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi

DRIFT_FILE="$PROJECT_ROOT/.doc-sentinel-drift.json"
MARKER_FILE="$PROJECT_ROOT/.doc-sentinel-last-session"

# No drift file — nothing to do
if [ ! -f "$DRIFT_FILE" ]; then
  exit 0
fi

# ─── Read session id from stdin ──────────────────────────────────────────────
# Claude Code passes a JSON envelope that includes session_id on Stop. We use
# it to block at most once per session. If jq or session_id is missing we
# still fire once (better a spurious block than silent drift).
INPUT=$(cat || true)
SESSION_ID=""
if command -v jq &>/dev/null && [ -n "$INPUT" ]; then
  SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)
fi

# If we've already blocked for this session, don't block again — the agent is
# presumably already working on it (or has given up on unresolvable entries).
if [ -n "$SESSION_ID" ] && [ -f "$MARKER_FILE" ]; then
  LAST_SESSION=$(cat "$MARKER_FILE" 2>/dev/null || true)
  if [ "$LAST_SESSION" = "$SESSION_ID" ]; then
    exit 0
  fi
fi

# ─── Build the directive reason ──────────────────────────────────────────────
build_reason() {
  local count="$1"
  local detail="$2"
  cat <<PROMPT
doc-sentinel: ${count} documentation drift warning(s) accumulated in .doc-sentinel-drift.json${detail}.

Before stopping, dispatch the drift-resolver subagent to process them. Use the Agent tool with subagent_type: "doc-sentinel:drift-resolver" and include these instructions in the prompt:

  1. Read .doc-sentinel-drift.json in the project root.
  2. For each warning, judge whether it's real drift (the doc section that
     references the changed source is now stale) or a false positive
     (basename match with no actual content drift).
  3. Update affected docs to match current source. Leave false positives alone.
  4. Rewrite .doc-sentinel-drift.json as an empty array ([]) or keep only
     entries you couldn't confidently resolve.
  5. Commit any doc changes with a 'docs:' prefix — the post-commit hook
     skips 'docs:' commits to prevent a feedback loop.

After the subagent reports back, you may stop. This hook will block at most
once per session, so if the subagent can't fully clear the file you won't be
trapped in a loop.
PROMPT
}

emit_block() {
  # Claude Code's Stop hook accepts two mechanisms to prevent the model from
  # stopping and feed back a directive:
  #
  #   1. JSON on stdout: `{"decision":"block","reason":"..."}`
  #   2. Exit code 2 with the reason on stderr
  #
  # Empirically, the JSON mechanism is not honored in all Claude Code
  # versions — the payload parses fine but the model still stops. Exit code 2
  # with stderr is the older universal contract and reliably blocks.
  local reason="$1"
  printf '%s\n' "$reason" >&2
  exit 2
}

# ─── Main ────────────────────────────────────────────────────────────────────
if command -v jq &>/dev/null; then
  WARNING_COUNT=$(jq 'length' "$DRIFT_FILE" 2>/dev/null || echo "0")
  if [ "$WARNING_COUNT" -eq 0 ] || [ "$WARNING_COUNT" = "null" ]; then
    exit 0
  fi

  UNIQUE_DOCS=$(jq -r '[.[].doc] | unique | length' "$DRIFT_FILE" 2>/dev/null || echo "?")
  UNIQUE_SOURCES=$(jq -r '[.[].source] | unique | length' "$DRIFT_FILE" 2>/dev/null || echo "?")
  DOC_LIST=$(jq -r '[.[].doc] | unique | join(", ")' "$DRIFT_FILE" 2>/dev/null || echo "")
  DETAIL=" — ${UNIQUE_SOURCES} source file(s) changed that are referenced in ${UNIQUE_DOCS} doc(s): ${DOC_LIST}"
else
  WARNING_COUNT=$(wc -l < "$DRIFT_FILE" | tr -d ' ')
  if [ "$WARNING_COUNT" -eq 0 ]; then
    exit 0
  fi
  DETAIL=""
fi

REASON=$(build_reason "$WARNING_COUNT" "$DETAIL")

# Record the marker BEFORE emit_block — that function calls `exit 2` so
# nothing after it runs. Best-effort: a failed write just means we might
# block twice for the same session, which is annoying but not looping.
if [ -n "$SESSION_ID" ]; then
  printf '%s' "$SESSION_ID" > "$MARKER_FILE" 2>/dev/null || true
fi

emit_block "$REASON"
