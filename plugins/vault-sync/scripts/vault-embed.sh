#!/usr/bin/env bash
# vault-embed.sh — Run qmd embed on a schedule (not on every file change).
# Processes only pending chunks — incremental, not a full re-embed.
# A lock file prevents overlapping runs if the previous embed is still running.
#
# Intended to be called by a systemd timer (Linux) or launchd plist (macOS),
# not by watchman directly.
#
# Environment variables:
#   QMD_VAULT    Path to vault (default: ~/Documents/My Vault)
#   QMD_LOG      Path to log file (default: ~/.local/log/vault-sync.log)

set -euo pipefail

VAULT="${QMD_VAULT:-$HOME/Documents/My Vault}"
LOG_FILE="${QMD_LOG:-$HOME/.local/log/vault-sync.log}"
LOCK_FILE="${TMPDIR:-/tmp}/vault-embed.lock"

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

# Skip if a previous embed is still running (model is slow)
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
  log "embed: skipped (previous run still in progress)"
  exit 0
fi
trap 'rm -rf "$LOCK_FILE"' EXIT

if ! command -v qmd &>/dev/null; then
  log "embed: ERROR — qmd not found in PATH"
  exit 1
fi

cd "$VAULT"

# Check if there's anything pending before spinning up the model
PENDING=$(qmd status 2>/dev/null | grep "Pending:" | grep -o '[0-9]*' || echo "0")
if [ "$PENDING" = "0" ]; then
  log "embed: nothing pending"
  exit 0
fi

log "embed: starting ($PENDING chunks pending)"

if output=$(qmd embed 2>&1); then
  log "embed: ok"
else
  log "embed: failed — $output"
  exit 1
fi
