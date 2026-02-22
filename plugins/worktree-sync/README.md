# worktree-sync

Augmented git worktree creation for Claude Code. When you run `claude --worktree`, this plugin automatically syncs gitignored files (secrets, env files, credentials) into the new worktree and runs optional post-create scripts.

## Prerequisites

- `jq` (for parsing hook input)
- Git

## How It Works

Claude Code's `WorktreeCreate` hook replaces the default worktree behavior entirely. This plugin handles both the git worktree creation **and** additional setup in one step:

1. Creates a git worktree at `.claude/worktrees/<name>` with branch `claude-worktree/<name>`
2. Reads `.worktreeinclude` to find gitignored files that should be symlinked into the worktree
3. Runs an optional post-create script for project-specific setup

When the worktree session ends, `WorktreeRemove` cleans up with `git worktree remove`.

## Setup

### 1. Copy scripts into your project

```bash
cp plugins/worktree-sync/scripts/worktree-create.sh your-project/scripts/
cp plugins/worktree-sync/scripts/worktree-remove.sh your-project/scripts/
chmod +x your-project/scripts/worktree-create.sh your-project/scripts/worktree-remove.sh
```

### 2. Add hooks to your project's `.claude/settings.json`

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/worktree-create.sh",
            "timeout": 120
          }
        ]
      }
    ],
    "WorktreeRemove": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/worktree-remove.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### 3. Create a `.worktreeinclude` in your project root

```
# Environment files
.env
.env.local

# Rails credentials
config/master.key

# Claude Code local settings
.claude/settings.local.json
```

> **Note:** Only files that match a pattern in `.worktreeinclude` **and** are actually gitignored will be synced.

## Configuration

### `.worktreesync`

Optional shell-sourceable config file in your project root:

```bash
# How to bring .worktreeinclude files into the worktree
# Options: "symlink" (default) or "copy"
WORKTREE_LINK_MODE="symlink"

# Script to run after worktree creation (relative to project root)
# Receives: $1=worktree_path, $2=worktree_name
# Working directory is set to the worktree
WORKTREE_POST_CREATE="scripts/worktree-setup.sh"
```

## Example Post-Create Script

```bash
#!/bin/bash
# scripts/worktree-setup.sh
WORKTREE_PATH="$1"
WORKTREE_NAME="$2"

echo "Setting up worktree: $WORKTREE_NAME" >&2

# Create isolated database config
DB_SUFFIX=$(echo "$WORKTREE_NAME" | tr '-' '_')
cat > .env.local << EOF
DB_DATABASE=myapp_dev_${DB_SUFFIX}
DB_TEST_DATABASE=myapp_test_${DB_SUFFIX}
EOF

# Run project setup
bin/setup >&2
```

## Usage

Once configured, just use `claude --worktree` as normal. The hooks handle the rest.

```bash
# Create a worktree session
claude --worktree

# Or with a specific name
claude --worktree my-feature
```

## Why settings.json instead of plugin hooks?

There is currently a [known issue](https://github.com/anthropics/claude-code/issues/16288) where hooks defined in a plugin's `hooks/hooks.json` are registered but never invoked. Until this is fixed, hooks must be configured directly in `.claude/settings.json` using `$CLAUDE_PROJECT_DIR` to reference scripts. This plugin still bundles the hook configuration in `hooks/hooks.json` so that when the bug is resolved, plugin-based installation will work automatically.

## Related Issues

- [#16288](https://github.com/anthropics/claude-code/issues/16288) - Plugin hooks not loaded from external hooks.json file
- [#27467](https://github.com/anthropics/claude-code/issues/27467) - WorktreeCreate stdout handling causes silent hang (redirect all git output to stderr)
- [#27744](https://github.com/anthropics/claude-code/issues/27744) - Feature request for PostWorktreeCreate hook
