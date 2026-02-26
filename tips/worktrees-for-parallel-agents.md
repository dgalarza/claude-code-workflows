# Use Worktrees for Parallel Agents

Git worktrees let you run multiple Claude Code agents on the same codebase without conflicts.

## The Problem

If you run 2+ agents on the same repo, you get:
- Unrelated changes in one branch
- Agents overwriting each other's files
- Test suites colliding on the same database

## The Solution

Each agent gets its own worktree via `claude --worktree`.

**But wait** - your app won't run because `.env` and other secrets don't copy over. And if both agents run tests, they'll fight over the same database.

## Automate It with .worktreeinclude

Claude Code natively supports `.worktreeinclude` when using `--worktree`. Add a `.worktreeinclude` to your project root and Claude Code will automatically symlink those files into new worktrees.

### Setup

1. Add a `.worktreeinclude` to your project root:
```
.env
.env.local
config/master.key
```

2. Run `claude --worktree` and your secrets are there automatically.

Only files matching both `.worktreeinclude` AND `.gitignore` are synced.

## Rails Apps

There's a standalone setup script for manual worktree creation:

```bash
./scripts/setup-rails-worktree.sh feature-branch
```

Get the script: [scripts/setup-rails-worktree.sh](../scripts/setup-rails-worktree.sh) | [example.worktreeinclude](../scripts/example.worktreeinclude) | [Git Worktrees Cheat Sheet](https://www.damiangalarza.com/downloads/git-worktree-cheatsheet?utm_source=github&utm_medium=readme&utm_campaign=claude-code-workflows)

The `rails-toolkit` plugin also includes `/rails-toolkit:linear-worktree` which automates this with Linear issue context.
