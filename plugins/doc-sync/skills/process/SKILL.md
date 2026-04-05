---
name: process
description: Manually process the pending documentation queue
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, Write, Edit, Agent
---

# Process

Manually trigger processing of the `.doc-queue.json` file. Use this when you want to process queued documentation tasks without waiting for the Stop hook, or when the Stop hook didn't fire (e.g., after a crash or manual queue edit).

## `/doc-sync:process`

### Phase 1: Check Queue

Read `.doc-queue.json` from the project root. If the file doesn't exist or contains an empty array, report: "No pending documentation tasks in the queue."

### Phase 2: Show Summary

Display the pending tasks grouped by type:

```
Pending documentation tasks:
  2 changelog (feat: add auth, fix: login bug)
  1 api-reference (src/auth.ts)
  1 env-config (.env)

Process all 4 tasks? [Y/n]
```

### Phase 3: Dispatch Doc Writer

Dispatch the doc-writer agent (`subagent_type: "doc-sync:doc-writer"`) with the project root path and queue file path. The agent will:

1. Read `.doc-sync.json` for configuration
2. Process each task in the queue
3. Write documentation updates
4. Commit with `docs:` prefix
5. Clear the queue

### Phase 4: Report Results

After the doc-writer agent completes, summarize what was done:

```
doc-sync processed 4 tasks:
  - Updated CHANGELOG.md (2 entries)
  - Updated docs/reference/auth.md
  - Updated docs/reference/configuration.md
  - Committed: docs: update documentation from recent changes
```

### Error Handling

- If `.doc-queue.json` is malformed, attempt to parse what's valid and report unparseable entries
- If the doc-writer agent fails, preserve the queue (don't clear it) and report the error
- If specific tasks fail but others succeed, clear only the successful tasks from the queue
