# vault-sync

Watches your Obsidian vault for `.md` file changes and automatically runs `qmd update` + `qmd embed` with a debounce window. Keeps your QMD full-text and vector indexes current without manual intervention.

Cross-platform: Linux (systemd user service) and macOS (watchman via Homebrew).

## How It Works

```
File saved (Obsidian or Claude Code)
  → watchman detects .md change
  → resets settle timer (default: 10s)
  → more changes? timer resets again
  → quiet for 10s
      → qmd update   (BM25/FTS5 text re-index, fast)
      → qmd embed    (local vector embeddings, incremental)
```

`qmd embed` only processes chunks that don't yet have vectors — it's incremental, not a full re-embed on every change. A burst of saves triggers one sync run after the burst settles.

## Requirements

- [watchman](https://facebook.github.io/watchman/) — file watching with native debounce
- [qmd](https://github.com/tobi/qmd) — vault search index
- macOS: `brew install watchman`
- Linux: `sudo apt install watchman` or [build from source](https://facebook.github.io/watchman/docs/install)

## Install

```bash
cd plugins/vault-sync/scripts
./install.sh
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `QMD_VAULT` | `~/Documents/My Vault` | Path to your Obsidian vault |
| `QMD_SETTLE` | `10000` | Debounce window in milliseconds |
| `QMD_LOG` | `~/.local/log/vault-sync.log` | Log file path |

```bash
# Custom vault path or debounce
QMD_VAULT="/path/to/vault" QMD_SETTLE=5000 ./install.sh
```

## What Gets Installed

### macOS
- Watchman trigger on the vault (persists across watchman daemon restarts)
- Watchman daemon managed automatically by Homebrew launchd — starts on login

### Linux
- Watchman trigger on the vault
- `~/.config/systemd/user/vault-watcher.service` — oneshot service that re-registers
  the watchman trigger on login (watchman loses watch registrations after reboot)

## Logs

```bash
tail -f ~/.local/log/vault-sync.log
```

```
[2026-02-22T18:30:01Z] Starting sync
[2026-02-22T18:30:01Z] update: ok
[2026-02-22T18:30:04Z] embed: ok
[2026-02-22T18:30:04Z] Done
```

## Testing

```bash
# Trigger a sync manually
touch "$HOME/Documents/My Vault/test-sync.md"
sleep 12  # wait for debounce
rm "$HOME/Documents/My Vault/test-sync.md"
tail ~/.local/log/vault-sync.log
```

## Checking Status

```bash
# See active watchman triggers
watchman trigger-list "$HOME/Documents/My Vault"

# Linux: check systemd service
systemctl --user status vault-watcher

# Check QMD pending embeddings
qmd status
```

## Uninstall

```bash
./uninstall.sh
```

## Adjust Debounce

10 seconds works well for normal writing sessions. Lower it if you want faster indexing after saves, higher if you're doing bulk imports.

```bash
# Re-run setup with different settle period (no need to reinstall)
QMD_SETTLE=5000 ./setup-trigger.sh
```
