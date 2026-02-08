# Memory System

A persistent, file-based memory system for Claude Code inspired by OpenClaw's memory architecture. Gives Claude durable context across sessions using daily logs, topic files, and lifecycle hooks.

## Install

```bash
/plugin install memory-system@dgalarza-workflows
```

## What It Does

Claude Code's auto-memory provides a `MEMORY.md` file that's always loaded into context. This plugin builds a complete memory system around that foundation:

- **Daily logs** — session-specific context appended to `memory/daily/YYYY-MM-DD.md`
- **Topic files** — durable knowledge organized by subject in `memory/topics/`
- **Active context** — current work state in `memory/topics/active-context.md`
- **200-line MEMORY.md** — structured template with section budgets

## How It Works

### 4 Lifecycle Hooks

| Hook | Event | What It Does |
|---|---|---|
| `session_start.py` | SessionStart | Loads today's + yesterday's daily logs and active context into the session |
| `memory_trigger.py` | UserPromptSubmit | Detects phrases like "remember this" or "done for today" and injects save reminders |
| `pre_compact.py` | PreCompact | Reminds Claude to flush important context before compaction truncates it |
| `stop_save.py` | Stop | Extracts session summary from transcript and appends to daily log |

### 4 Skills

| Skill | Command | Purpose |
|---|---|---|
| memory-init | `/memory-init` | Bootstrap directory structure and MEMORY.md (run once) |
| memory-save | `/memory-save` | Save decisions, facts, and context to the right memory file |
| memory-search | `/memory-search` | Tiered search across all memory files |
| memory-review | `/memory-review` | Weekly maintenance: compact logs, audit staleness, report health |

## Memory Architecture

```
~/.claude/projects/{project}/memory/
├── MEMORY.md           # Always in context (200-line cap)
├── daily/
│   ├── 2026-02-08.md   # Today's session log
│   └── 2026-02-07.md   # Yesterday's session log
├── topics/
│   ├── active-context.md  # Current work state
│   ├── architecture.md    # Durable knowledge
│   └── decisions.md       # Key decisions log
└── archive/
    └── 2026-01-W4.md      # Compacted weekly logs
```

## OpenClaw Inspiration

This plugin adapts [OpenClaw](https://github.com/cline/OpenClaw)'s file-first memory approach to Claude Code:

| OpenClaw Feature | Claude Code Implementation |
|---|---|
| MEMORY.md always loaded | Same — auto-memory MEMORY.md |
| Daily logs (today + yesterday) | SessionStart hook injects as `additionalContext` |
| Pre-compaction flush | PreCompact hook injects save reminder |
| Session save on reset | Stop hook extracts transcript summary |
| Auto-capture triggers | UserPromptSubmit hook detects memory phrases |
| Vector search | Grep-based search over structured files |

## Getting Started

1. Install the plugin
2. Run `/memory-init` to bootstrap the directory structure
3. Work normally — hooks handle daily logs automatically
4. Use `/memory-save` for explicit saves
5. Run `/memory-review` weekly to maintain the system

## CLAUDE.md Integration

For the best experience, add the memory system instructions to your project's CLAUDE.md. See `docs/claude-md-instructions.md` for a ready-to-paste snippet.
