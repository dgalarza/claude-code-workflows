---
name: memory-init
description: Initialize the memory directory structure for a project. Creates daily/, topics/, and archive/ directories and populates MEMORY.md interactively with the user's identity, active projects, and preferences. Run once per project to bootstrap the memory system.
---

# Memory Init

Initialize the persistent memory system for this project.

## Instructions

Follow these steps to set up the memory system:

### Step 1: Determine Memory Path

The memory directory lives at the Claude auto-memory path for this project:
```
~/.claude/projects/{sanitized_cwd}/memory/
```

Where `{sanitized_cwd}` is the current working directory with `/` replaced by `-` and leading `-` stripped.

Check if the memory directory already exists. If it does, inform the user and ask if they want to reinitialize.

### Step 2: Create Directory Structure

Create the following directories:
```
memory/
├── daily/      # Session logs, one file per day (YYYY-MM-DD.md)
├── topics/     # Durable knowledge files by topic
└── archive/    # Compacted/archived daily logs
```

Also ensure MEMORY.md exists at the memory root.

### Step 3: Populate MEMORY.md

Read the project's CLAUDE.md to gather context about the user and project. Then interactively fill in MEMORY.md sections:

1. **Identity** (~10 lines): Who the user is, their role, key background
2. **Active Projects** (~20 lines): Current focus areas with brief descriptions
3. **Key Decisions** (~30 lines): Leave empty for now, will fill over time
4. **Preferences** (~15 lines): Coding style, tools, communication preferences
5. **Relationships** (~10 lines): Key people mentioned in CLAUDE.md
6. **Conventions** (~20 lines): Project-specific patterns
7. **Quick Reference** (~15 lines): Frequently needed links, IDs
8. **Memory Index** (~10 lines): Will grow as topic files are created

Present the populated MEMORY.md to the user for review before writing.

### Step 4: Create Active Context

Create `memory/topics/active-context.md` with:
```markdown
# Active Context

Current focus and state for this project.

## Current Focus
<!-- What you're actively working on -->

## Recent Changes
<!-- What changed recently that's relevant -->

## Open Questions
<!-- Unresolved decisions or blockers -->
```

### Step 5: Confirm Setup

Report what was created:
- Directory structure
- MEMORY.md line count (should be well under 200)
- Remind user about the memory skills: `/memory-save`, `/memory-search`, `/memory-review`

## Important Notes

- MEMORY.md has a hard 200-line cap — lines after 200 are truncated from Claude's context
- Keep entries concise: one line per fact, no verbose descriptions
- The Memory Index section links to topic files for deeper context
- Daily logs are auto-managed by the SessionStart and Stop hooks
