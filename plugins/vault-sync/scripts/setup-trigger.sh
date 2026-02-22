#!/usr/bin/env bash
# setup-trigger.sh — Configure watchman trigger for vault QMD sync.
# Idempotent: safe to run multiple times or after reboot.
#
# Environment variables:
#   QMD_VAULT     Path to vault (default: ~/Documents/My Vault)
#   QMD_SETTLE    Debounce period in ms (default: 10000 = 10s)

set -euo pipefail

VAULT="${QMD_VAULT:-$HOME/Documents/My Vault}"
SETTLE="${QMD_SETTLE:-10000}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/vault-sync.sh"

if ! command -v watchman &>/dev/null; then
  echo "ERROR: watchman not found. Install it first:"
  echo "  macOS:  brew install watchman"
  echo "  Linux:  sudo apt install watchman  (or see https://facebook.github.io/watchman/)"
  exit 1
fi

if [ ! -f "$SYNC_SCRIPT" ]; then
  echo "ERROR: vault-sync.sh not found at $SYNC_SCRIPT"
  exit 1
fi

chmod +x "$SYNC_SCRIPT"

echo "Configuring watchman trigger..."
echo "  Vault:   $VAULT"
echo "  Settle:  ${SETTLE}ms"
echo "  Script:  $SYNC_SCRIPT"

# Start watching the vault (no-op if already watched)
watchman watch "$VAULT" > /dev/null

# Remove existing trigger for idempotency
watchman trigger-del "$VAULT" qmd-sync 2>/dev/null || true

# Add trigger with settle debounce
# - expression: only fire on .md file changes
# - settle: wait Nms after last change before firing
# - stdin: /dev/null (we don't need the file list — qmd update scans everything)
watchman -j <<EOF
["trigger", "$VAULT", {
  "name": "qmd-sync",
  "expression": ["suffix", "md"],
  "settle": $SETTLE,
  "command": ["$SYNC_SCRIPT"],
  "stdin": "/dev/null",
  "append_files": false
}]
EOF

echo "✓ Watchman trigger active (${SETTLE}ms debounce)"
echo ""
echo "Logs: ${QMD_LOG:-$HOME/.local/log/vault-sync.log}"
echo "Test: touch \"$VAULT/test-sync.md\" && sleep 12 && rm \"$VAULT/test-sync.md\""
