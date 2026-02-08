---
name: memory-search
description: Search across all memory files to find relevant context, decisions, or knowledge. Uses a tiered approach starting with MEMORY.md (already in context), then recent daily logs, then grep across all memory files. Use when you need to recall decisions, find past context, or check what's been recorded about a topic.
---

# Memory Search

Search your persistent memory for relevant context.

## Instructions

When searching memory, follow this tiered approach from fastest to most thorough:

### Tier 1: Check MEMORY.md (Already in Context)

MEMORY.md is auto-loaded into every session. Check it first — the answer may already be in your context window. Look for:
- The specific fact or decision
- A link in the Memory Index pointing to a relevant topic file

If found, report the result and stop.

### Tier 2: Check Recent Daily Logs

List and read recent daily log files:

```
memory/daily/YYYY-MM-DD.md
```

Check the last 3-5 daily logs for session-specific context. These contain:
- Decisions made during sessions
- File operations performed
- Next steps and open questions

### Tier 3: Search Topic Files

List all topic files in `memory/topics/` and read any that seem relevant based on filename.

Topic files contain durable knowledge organized by subject. Check filenames first to narrow your search.

### Tier 4: Full-Text Search

Use Grep to search across the entire memory directory:

```
Grep pattern="search_term" path="memory/"
```

This catches anything missed by filename-based browsing.

### Tier 5: Check Archive

If nothing found in active files, check `memory/archive/` for older compacted logs.

## Reporting Results

After searching, report:
1. **Where found**: Which file(s) contained relevant information
2. **The content**: The actual facts, decisions, or context found
3. **Freshness**: When the information was recorded (date from filename or entry)
4. **Confidence**: Whether this is definitive or may be outdated

If nothing is found, say so clearly and suggest the user might want to record the information using `/memory-save`.

## Search Tips

- Use specific keywords rather than broad queries
- Date-based searches work well with daily log filenames (YYYY-MM-DD)
- Topic file names are descriptive — scan filenames before reading contents
- The Memory Index in MEMORY.md is a curated directory of topic files
