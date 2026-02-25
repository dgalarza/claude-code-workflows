#!/usr/bin/env bash
# install.sh — Platform-aware installer for vault-sync.
#
# Installs two independent pieces:
#   1. watchman trigger → vault-sync.sh (qmd update on file change, debounced)
#   2. systemd timer or launchd plist → vault-embed.sh (qmd embed every 30 min)
#
# Usage:
#   ./install.sh
#   QMD_VAULT="/path/to/vault" QMD_SETTLE=5000 ./install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="$SCRIPT_DIR/../systemd"
OS="$(uname -s)"
VAULT="${QMD_VAULT:-$HOME/Documents/My Vault}"
SETTLE="${QMD_SETTLE:-10000}"
LOG="${QMD_LOG:-$HOME/.local/log/vault-sync.log}"

chmod +x "$SCRIPT_DIR/vault-sync.sh" "$SCRIPT_DIR/vault-embed.sh" "$SCRIPT_DIR/setup-trigger.sh"

echo "vault-sync installer"
echo "OS: $OS"
echo "Vault: $VAULT"
echo ""

# ── macOS ──────────────────────────────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  if ! command -v watchman &>/dev/null; then
    echo "Installing watchman via Homebrew..."
    brew install watchman
  else
    echo "✓ watchman $(watchman --version)"
  fi

  # 1. Watchman trigger for qmd update
  QMD_VAULT="$VAULT" QMD_SETTLE="$SETTLE" "$SCRIPT_DIR/setup-trigger.sh"

  # 2. launchd plist for qmd embed every 30 min
  PLIST_DIR="$HOME/Library/LaunchAgents"
  PLIST_FILE="$PLIST_DIR/com.damiangalarza.vault-embed.plist"
  mkdir -p "$PLIST_DIR"

  cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.damiangalarza.vault-embed</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT_DIR/vault-embed.sh</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>QMD_VAULT</key>
    <string>$VAULT</string>
    <key>QMD_LOG</key>
    <string>$LOG</string>
  </dict>
  <key>StartInterval</key>
  <integer>1800</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$HOME/.local/log/vault-embed-launchd.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/.local/log/vault-embed-launchd.log</string>
</dict>
</plist>
EOF

  launchctl unload "$PLIST_FILE" 2>/dev/null || true
  launchctl load "$PLIST_FILE"
  echo "✓ launchd plist: $PLIST_FILE (every 30 min)"

  echo ""
  echo "✓ Install complete (macOS)"

# ── Linux ──────────────────────────────────────────────────────────────────────
elif [ "$OS" = "Linux" ]; then
  if ! command -v watchman &>/dev/null; then
    echo "ERROR: watchman not found."
    echo "  Ubuntu/Debian: sudo apt install watchman"
    echo "  See: https://facebook.github.io/watchman/docs/install"
    exit 1
  else
    echo "✓ watchman $(watchman --version)"
  fi

  SERVICE_DIR="$HOME/.config/systemd/user"
  mkdir -p "$SERVICE_DIR"

  # 1. Watchman trigger for qmd update + watcher service to survive reboots
  QMD_VAULT="$VAULT" QMD_SETTLE="$SETTLE" "$SCRIPT_DIR/setup-trigger.sh"

  sed "s|SETUP_TRIGGER_SCRIPT|$SCRIPT_DIR/setup-trigger.sh|g; \
       s|QMD_VAULT_VALUE|$VAULT|g; \
       s|QMD_SETTLE_VALUE|$SETTLE|g" \
    "$SYSTEMD_DIR/vault-watcher.service" > "$SERVICE_DIR/vault-watcher.service"

  # 2. systemd timer for qmd embed every 30 min
  sed "s|VAULT_EMBED_SCRIPT|$SCRIPT_DIR/vault-embed.sh|g; \
       s|QMD_VAULT_VALUE|$VAULT|g; \
       s|QMD_LOG_VALUE|$LOG|g" \
    "$SYSTEMD_DIR/vault-embed.service" > "$SERVICE_DIR/vault-embed.service"

  cp "$SYSTEMD_DIR/vault-embed.timer" "$SERVICE_DIR/vault-embed.timer"

  systemctl --user daemon-reload

  systemctl --user enable --now vault-watcher.service
  systemctl --user enable --now vault-embed.timer

  echo "✓ vault-watcher.service (watchman trigger on login)"
  echo "✓ vault-embed.timer (qmd embed every 30 min)"

  echo ""
  echo "✓ Install complete (Linux)"
  echo "  Status: systemctl --user status vault-watcher vault-embed.timer"

else
  echo "ERROR: Unsupported OS: $OS"
  exit 1
fi

echo "  Logs: $LOG"
