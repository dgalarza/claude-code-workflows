---
name: stale
description: Find documentation that is out of date relative to code changes
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep
---

# Stale

Find documentation files that may be out of date relative to the source code they document. Outputs a staleness report with scores and recommendations. Complements doc-audit's accuracy dimension with temporal analysis.

## `/doc-sync:stale`

### Phase 1: Read Configuration

If `.doc-sync.json` exists in the project root, read it to determine documentation paths. Use the configured output paths to locate doc files and the `paths` globs to identify which source files are related to which doc types.

If `.doc-sync.json` does not exist, use defaults:
- Docs root: `docs/`
- Changelog: `CHANGELOG.md`
- Architecture: `ARCHITECTURE.md`

### Phase 2: Discover Documentation

Glob all markdown files in the docs root (from config or default `docs/`). Also check for the changelog file and architecture file at their configured paths. Include `AGENTS.md` and `CLAUDE.md` if they exist.

If no documentation files are found, report: "No documentation files found. Nothing to check for staleness."

### Phase 3: Analyze Each Document

For each documentation file:

1. **Get doc modification date**: Run `git log -1 --format="%ci" -- <doc-path>` to get the last commit date that touched this file. If the file is untracked, use its filesystem mtime.

2. **Identify referenced source files**: Read the first 50 lines of the doc. Look for:
   - Explicit file references (paths like `src/auth.ts`, `lib/utils.py`, `packages/agents/`)
   - Code blocks with language identifiers that suggest source files
   - Import statements or module names mentioned in prose
   - For reference docs, use the configured `paths` globs from `.doc-sync.json` to identify related source directories
   - For agent-schemas docs, look for agent/tool names and map to their source files

3. **Get source modification dates**: For each referenced source file that exists, run `git log -1 --format="%ci" -- <source-path>`.

4. **Calculate staleness**: If any referenced source file was modified after the doc file, the doc is potentially stale. Staleness score:
   - **Fresh** (0): Doc was updated after all referenced sources
   - **Mild** (1): Source changed within 7 days after doc
   - **Stale** (2): Source changed 7-30 days after doc
   - **Very stale** (3): Source changed more than 30 days after doc

### Phase 4: Generate Report

Output the report sorted by staleness score (most stale first):

```
doc-sync Staleness Report
=========================

Very Stale (3):
  docs/reference/auth.md
    Last updated: 2026-01-15
    Stale because: src/auth.ts changed 2026-03-20 (64 days newer)
    Recommendation: Review and update API reference

Stale (2):
  docs/guides/setup.md
    Last updated: 2026-02-28
    Stale because: package.json changed 2026-03-15 (15 days newer)
    Recommendation: Check if setup steps are still accurate

Fresh (0):
  docs/decisions/0001-use-postgresql.md — up to date
  docs/reference/utils.md — up to date

Summary: 5 docs checked, 1 very stale, 1 stale, 0 mild, 3 fresh
```

### Phase 5: Recommend Actions

Based on findings, suggest concrete next steps:

- **Very stale docs** → "Run `/doc-sync:capture` to auto-update, or review manually"
- **Multiple stale docs** → "Run doc-audit in fix mode for comprehensive repair"
- **Agent-schemas stale** → "Agent capabilities may have changed — review tool tables for accuracy"
- **All fresh** → "Documentation is current. No action needed."

### Rules

- This skill is **read-only** — it reports staleness but does not modify any files
- If a doc file references no identifiable source files, mark it as "No source references found — manual review recommended"
- ADRs (files in the decisions directory) are exempt from staleness by default since they are point-in-time records. Include them in the report as "ADR — staleness N/A"
- Changelog staleness is determined by comparing its last update against the most recent non-docs commit
