#!/usr/bin/env bash
# uninstall.sh — Remove vault-sync watchman trigger and system services.

set -euo pipefail

VAULT="${QMD_VAULT:-$HOME/Documents/My Vault}"
OS="$(uname -s)"

echo "Removing vault-sync..."

# Remove watchman trigger
if command -v watchman &>/dev/null; then
  watchman trigger-del "$VAULT" qmd-sync 2>/dev/null \
    && echo "✓ Watchman trigger removed" \
    || echo "  No trigger found (already removed)"
fi

if [ "$OS" = "Linux" ]; then
  for unit in vault-watcher.service vault-embed.timer vault-embed.service; do
    FILE="$HOME/.config/systemd/user/$unit"
    if [ -f "$FILE" ]; then
      systemctl --user stop "$unit" 2>/dev/null || true
      systemctl --user disable "$unit" 2>/dev/null || true
      rm "$FILE"
      echo "✓ Removed $unit"
    fi
  done
  systemctl --user daemon-reload

elif [ "$OS" = "Darwin" ]; then
  PLIST="$HOME/Library/LaunchAgents/com.damiangalarza.vault-embed.plist"
  if [ -f "$PLIST" ]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm "$PLIST"
    echo "✓ Removed launchd plist"
  fi
fi

echo "✓ Uninstall complete"
echo "  Log file kept at: ${QMD_LOG:-$HOME/.local/log/vault-sync.log}"
