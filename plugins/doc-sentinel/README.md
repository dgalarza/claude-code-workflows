# doc-sentinel

Proactive documentation drift detector for Claude Code. Hooks into every commit to identify docs that reference changed code, flags drift before staleness accumulates, and resolves warnings with targeted fixes.

## How It Fits

The documentation lifecycle has three layers:

| Layer | Plugin | When |
|-------|--------|------|
| **Scaffold** | [agent-ready](../agent-ready/) | One-time setup — creates AGENTS.md, ARCHITECTURE.md, docs/ |
| **Write** | [doc-sync](../doc-sync/) | Continuous — generates and updates docs when code changes |
| **Guard** | **doc-sentinel** | Continuous — catches when existing docs drift from code reality |
| **Audit** | [doc-audit](../doc-audit/) | On-demand — full accuracy/freshness validation |

doc-sync writes docs. doc-sentinel catches when those docs go wrong.

## Quick Start

```bash
# 1. Configure what to watch
/doc-sentinel:setup

# 2. Run a baseline drift scan
/doc-sentinel:scan

# 3. Fix any drift found
/doc-sentinel:resolve
```

After setup, hooks run automatically — no manual invocation needed for ongoing detection.

## How It Works

```
Developer commits code
    │
    ▼
PostToolUse hook fires (detects git commit)
    ├─ Extracts changed source files
    ├─ Scans all docs for references to those files
    ├─ Cross-references: file paths, module names, directory paths
    └─ Queues drift warnings to .doc-sentinel-drift.json
    │
    ▼
Session continues (warnings accumulate)
    │
    ▼
Stop hook fires (end of session)
    ├─ Counts accumulated warnings
    ├─ Summarizes affected docs
    └─ Prompts: "Run /doc-sentinel:resolve to fix N drift warnings"
    │
    ▼
/doc-sentinel:resolve
    ├─ Groups warnings by doc file
    ├─ Reads doc + source to classify drift
    ├─ Fixes real drift, dismisses false positives
    ├─ Dispatches drift-resolver agent for complex cases
    └─ Commits with docs: prefix, clears queue
```

## Commands

| Command | Purpose |
|---------|---------|
| `/doc-sentinel:setup` | Configure drift detection for the project |
| `/doc-sentinel:scan` | Full-codebase drift scan (read-only) |
| `/doc-sentinel:resolve` | Process and fix accumulated drift warnings |

## What It Detects

### Critical Drift (broken references)
- File paths in docs that point to moved/deleted files
- Directory references to restructured modules
- Commands (pnpm scripts, etc.) that no longer exist

### Stale References
- Source files changed significantly since the doc was last updated
- API endpoints or function signatures that evolved
- Configuration values (ports, env vars) that shifted

### Warnings
- Port numbers in docs that conflict with docker-compose or .env
- Env vars documented but not found in source
- Symlink integrity (CLAUDE.md → AGENTS.md)

## Configuration

`.doc-sentinel.json` (created by `/doc-sentinel:setup`):

```json
{
  "version": 1,
  "docs_root": "docs",
  "watch_files": ["AGENTS.md", "ARCHITECTURE.md", "README.md"],
  "ignore_sources": ["*.test.*", "*.spec.*", "__tests__/**", "*.d.ts"],
  "ignore_docs": [],
  "severity": {
    "architecture": "high",
    "agents_md": "high",
    "api_reference": "medium",
    "changelog": "low",
    "readme": "medium"
  }
}
```

| Field | Purpose |
|-------|---------|
| `docs_root` | Primary documentation directory |
| `watch_files` | Additional doc files outside docs_root to monitor |
| `ignore_sources` | Source file patterns to skip (tests, type defs) |
| `ignore_docs` | Doc files to exclude from drift checks |
| `severity` | Controls when drift is flagged (high/medium/low) |

## Drift Queue Format

`.doc-sentinel-drift.json` — ephemeral, session-scoped:

```json
[
  {
    "source": "src/routes/auth.ts",
    "doc": "ARCHITECTURE.md",
    "commit": "abc1234",
    "message": "refactor: restructure auth module",
    "timestamp": "2026-04-07T10:00:00Z"
  }
]
```

Add `.doc-sentinel-drift.json` to `.gitignore` — it is not meant to be committed.

## Agents

### drift-resolver

Dispatched by `/doc-sentinel:resolve` for complex drift cases (>5 warnings per doc or multi-section updates). Reads both docs and source diffs, applies coordinated updates, and verifies coherence after changes.

## Rules

### doc-references

Applied to all `.md` files. Encourages documentation practices that make drift detection reliable: backtick-quoted paths, relative references, co-located doc updates.

## Companion Plugins

doc-sentinel works alongside but does not conflict with:

- **doc-sync / inkwell** — They generate docs; sentinel catches when those docs drift. Separate queue files, no interference.
- **agent-ready** — Sentinel monitors the artifacts that agent-ready scaffolds (AGENTS.md, ARCHITECTURE.md).
- **doc-audit** — Sentinel catches drift proactively; doc-audit provides periodic deep validation. Use both for comprehensive coverage.

## Installation

### From the marketplace

```bash
claude install dgalarza-workflows/doc-sentinel
```

### From local source

```bash
claude install ./plugins/doc-sentinel
```

### Manual

Copy the `plugins/doc-sentinel/` directory into your project's `.claude/plugins/` directory.

## Troubleshooting

**Hook not firing:** Verify `hooks.json` is loaded — check Claude Code plugin settings. The PostToolUse hook only fires on Bash tool use containing `git commit`.

**Too many false positives:** Tune `ignore_sources` in `.doc-sentinel.json` to skip files that docs reference generically (e.g., test files, generated types). The `resolve` skill lets you dismiss false positives.

**Conflicts with doc-sync:** None expected — they use separate queue files (`.doc-sync-queue.json` vs `.doc-sentinel-drift.json`) and separate hook scripts. Both can be active simultaneously.

**jq not installed:** The hook scripts have a fallback mode without jq, but functionality is limited (no config-driven ignore patterns, basic line-count reporting). Install jq for full drift detection: `brew install jq` / `apt install jq`.
