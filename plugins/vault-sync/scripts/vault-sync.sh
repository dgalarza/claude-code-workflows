#!/usr/bin/env bash
# vault-sync.sh — Called by watchman when .md files change in the vault.
# Runs qmd update (fast BM25/FTS5 text re-index only).
# Vector embeddings (qmd embed) are handled separately on a schedule.
#
# A lock file prevents concurrent runs if watchman fires multiple triggers
# before the previous sync finishes.
#
# Environment variables:
#   QMD_VAULT    Path to vault (default: ~/Documents/My Vault)
#   QMD_LOG      Path to log file (default: ~/.local/log/vault-sync.log)

set -euo pipefail

VAULT="${QMD_VAULT:-$HOME/Documents/My Vault}"
LOG_FILE="${QMD_LOG:-$HOME/.local/log/vault-sync.log}"
LOCK_FILE="${TMPDIR:-/tmp}/vault-sync.lock"

# Add common bun/qmd install locations to PATH
export PATH="$HOME/.bun/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
# Snap bun (Linux)
if [ -d "$HOME/snap/bun-js" ]; then
  SNAP_BUN=$(find "$HOME/snap/bun-js" -name "qmd" -path "*/bin/*" 2>/dev/null | head -1)
  [ -n "$SNAP_BUN" ] && export PATH="$(dirname "$SNAP_BUN"):$PATH"
fi

mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" >> "$LOG_FILE"
}

# Acquire lock — skip if another sync is already running
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
  log "update: skipped (sync already running)"
  exit 0
fi
trap 'rm -rf "$LOCK_FILE"' EXIT

if ! command -v qmd &>/dev/null; then
  log "ERROR: qmd not found in PATH"
  exit 1
fi

if [ ! -d "$VAULT" ]; then
  log "ERROR: Vault not found at $VAULT"
  exit 1
fi

cd "$VAULT"

if output=$(qmd update 2>&1); then
  log "update: ok"
else
  log "update: failed — $output"
fi
