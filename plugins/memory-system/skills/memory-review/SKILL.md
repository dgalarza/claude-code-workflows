---
name: memory-review
description: Maintenance workflow for the memory system. Audits MEMORY.md line count and staleness, compacts daily logs older than 7 days into topic files, reviews topic files for duplicates, and reports memory health stats. Run weekly to keep the memory system clean and useful.
---

# Memory Review

Maintain and optimize the memory system. Run this weekly.

## Instructions

Perform the following maintenance steps, reporting findings as you go. **Do not make changes without user approval** — present proposed changes and wait for confirmation.

### Step 1: MEMORY.md Audit

Read `memory/MEMORY.md` and report:
- **Line count**: Current vs. 200-line cap
- **Empty sections**: Sections with no content
- **Stale entries**: Decisions or facts with old dates that may need updating
- **Missing index entries**: Topic files that exist but aren't in the Memory Index

Propose specific changes:
- Remove stale entries (list them)
- Move verbose entries to topic files
- Add missing index entries

### Step 2: Daily Log Compaction

List all files in `memory/daily/`. For logs **older than 7 days**:

1. Read each old daily log
2. Extract durable knowledge (decisions, patterns, conventions)
3. Propose merging extracted content into relevant topic files
4. Propose moving the daily log to `memory/archive/`

**Do not delete or move files until the user approves.**

### Step 3: Topic File Review

List and read all files in `memory/topics/`. Check for:
- **Duplicates**: Same information in multiple files
- **Staleness**: Information that may be outdated
- **Organization**: Files that should be merged or split
- **Orphans**: Topic files not referenced in MEMORY.md Memory Index

Propose specific changes.

### Step 4: Active Context Check

Read `memory/topics/active-context.md` and verify:
- Current focus is still accurate
- Open questions have been resolved (or are still open)
- Recent changes section is up to date

Propose updates.

### Step 5: Memory Health Report

Summarize the memory system's health:

```
## Memory Health Report

- MEMORY.md: XX/200 lines (XX% capacity)
- Daily logs: XX files (XX active, XX ready to archive)
- Topic files: XX files
- Archive: XX files
- Last review: YYYY-MM-DD

### Recommendations
- [List any proposed actions]
```

Write the review date to MEMORY.md after completing the review (with user approval).

## Compaction Guidelines

When extracting from daily logs to topic files:
- Only extract **durable** knowledge (not session-specific noise)
- Decisions and their rationale are always worth keeping
- File paths and specific commands are usually session-specific (skip)
- Progress updates compress well: "Completed X migration" vs. step-by-step
- When in doubt, keep it — disk space is cheap, lost context is expensive

## Schedule

Run this skill weekly, ideally at the start of the week. The daily logs from the previous week provide a natural review boundary.
