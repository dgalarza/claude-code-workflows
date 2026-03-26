# Claude Code `.gitignore` Template

Add these entries to your project's `.gitignore` to keep local Claude Code configuration out of version control.

```gitignore
# Claude Code — local overrides (any nesting level)
CLAUDE.local.md

# Claude Code — local settings and credentials
.claude/**/*.local.*

# Claude Code — worktree state
.claude/worktrees
```

## What each entry does

| Pattern | Purpose |
|---------|---------|
| `CLAUDE.local.md` | Personal instructions that shouldn't be shared — matches at any directory depth |
| `.claude/**/*.local.*` | Local settings files (e.g., `settings.local.json`) |
| `.claude/worktrees` | Temporary worktree metadata created during agent isolation |
