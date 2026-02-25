# Memory System - CLAUDE.md Instructions

> Copy this section into your project's CLAUDE.md to teach Claude how to use the memory system.

---

## Memory System

This project uses a persistent file-based memory system. Memory files live in your auto-memory directory and persist across sessions.

### Memory Directory Structure

```
memory/
├── MEMORY.md           # Always loaded into context (200-line cap)
├── daily/              # Session logs (YYYY-MM-DD.md)
│   ├── 2026-02-08.md
│   └── 2026-02-07.md
├── topics/             # Durable knowledge by topic
│   ├── active-context.md
│   ├── architecture.md
│   └── decisions.md
└── archive/            # Compacted old daily logs
```

### When to Save to Memory

Save to memory when any of these occur:
- **Decision made**: Record the decision, alternatives considered, and rationale
- **Fact learned**: New information about the project, user, or domain
- **Preference expressed**: User's preferred approaches, tools, or patterns
- **Context switch**: Before changing topics, save current state
- **Session end**: Summarize what was accomplished and what's next
- **Before compaction**: Save anything important before context is truncated

### How to Save

**Choose the right destination:**

| What | Where | Example |
|---|---|---|
| Session work | `memory/daily/YYYY-MM-DD.md` | "Completed API migration steps 1-3" |
| Durable knowledge | `memory/topics/{topic}.md` | "API uses JWT auth with 1-hour expiry" |
| Current state | `memory/topics/active-context.md` | "Working on auth refactor, step 3 of 5" |
| Core facts | `memory/MEMORY.md` | "Prefers Ruby over Python" |

**Rules:**
1. Read the target file first to avoid duplicates
2. Keep entries to one line per fact
3. Date your entries: `- Chose PostgreSQL over MySQL (2026-02-08)`
4. Never store secrets (API keys, passwords, tokens)
5. Keep MEMORY.md under 200 lines — move details to topic files

### How to Search Memory

1. Check MEMORY.md (already in context)
2. Check the Memory Index section for relevant topic files
3. Read recent daily logs for session-specific context
4. Grep across `memory/` for full-text search

### The 200-Line Budget

MEMORY.md is always loaded into your system prompt. Lines after 200 are truncated. Manage the budget:

| Section | Budget |
|---|---|
| Identity | ~10 lines |
| Active Projects | ~20 lines |
| Key Decisions | ~30 lines |
| Preferences | ~15 lines |
| Relationships | ~10 lines |
| Conventions | ~20 lines |
| Quick Reference | ~15 lines |
| Memory Index | ~10 lines |
| **Total** | **~130 lines (70 lines buffer)** |

### Available Skills

- `/memory-init` — Bootstrap memory directory structure (run once)
- `/memory-save` — Save important context to memory files
- `/memory-search` — Search across all memory files
- `/memory-review` — Weekly maintenance (compact logs, audit MEMORY.md)

### Session Lifecycle (Automated by Hooks)

1. **Session start**: Recent daily logs auto-loaded as additional context
2. **During session**: Memory trigger phrases detected, save reminders injected
3. **Before compaction**: Reminder to flush important context to files
4. **Session end**: Session summary auto-extracted from transcript to daily log
