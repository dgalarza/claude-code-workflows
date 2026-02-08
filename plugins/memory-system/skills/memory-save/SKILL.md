---
name: memory-save
description: Save context, decisions, facts, or preferences to the memory system. Guides you through choosing the right destination (daily log, topic file, or MEMORY.md), reads the target file to avoid duplicates, and appends concisely. Use after important decisions, before context switches, or at session end.
---

# Memory Save

Save important context to your persistent memory files.

## Instructions

When the user invokes this skill (or when triggered by the memory system hooks), follow this workflow:

### Step 1: Assess What to Save

Review the current conversation and identify items worth persisting:

- **Decisions made** and their rationale
- **Facts learned** about the project, people, or systems
- **Preferences expressed** by the user
- **Progress** on current tasks (what was done, what's left)
- **Active context** (current focus, open questions, blockers)
- **Conventions discovered** (patterns, naming, architecture)

If invoked explicitly by the user, ask them what specifically they want saved if it's not obvious from context.

### Step 2: Choose Destination

Route each piece of information to the right file:

| Information Type | Destination | When |
|---|---|---|
| Session progress, daily work | `memory/daily/YYYY-MM-DD.md` | Every session |
| Durable knowledge, patterns | `memory/topics/{topic}.md` | When a topic solidifies |
| Active work state | `memory/topics/active-context.md` | Context switches |
| Frequently needed facts | `memory/MEMORY.md` | Core identity/preferences |

**Destination rules:**
- **MEMORY.md**: Only for facts needed in *every* session. Keep under 200 lines total.
- **Topic files**: For deep context on specific subjects. Name descriptively (e.g., `api-architecture.md`, `deployment-process.md`).
- **Daily logs**: For session-specific context. Structured with timestamps.
- **Active context**: Updated on context switches. Contains current focus and open items.

### Step 3: Read Before Writing

**Always read the target file first** to:
- Avoid duplicating existing entries
- Understand current structure and formatting
- Find the right insertion point

If the file doesn't exist yet, create it with an appropriate header.

### Step 4: Write Concisely

Append to the target file following these formatting rules:

**For daily logs:**
```markdown
## HH:MM - Brief description

- Decision: chose X over Y because Z
- Created: path/to/file.ext
- Progress: completed steps 1-3 of migration
- Next: finish step 4, then run tests
```

**For topic files:**
```markdown
## Section Name

- Key fact or pattern
- Another related fact
- Link to [[related topic]] if applicable
```

**For MEMORY.md:**
```markdown
- Single line fact with date (YYYY-MM-DD)
```

### Step 5: Update Memory Index

If you created a new topic file, add it to the Memory Index section of MEMORY.md:
```markdown
- [topic-name](topics/topic-name.md) - brief description
```

### Step 6: Confirm

Report what was saved and where:
- File(s) modified
- Number of lines added
- Current MEMORY.md line count (if modified)

## Important Notes

- **200-line cap on MEMORY.md**: If approaching the limit, move detailed content to topic files and keep only summary lines in MEMORY.md
- **One fact per line**: Keep entries scannable
- **Date your entries**: Include dates for decisions and facts that may become stale
- **No secrets**: Never store API keys, passwords, or tokens in memory files
