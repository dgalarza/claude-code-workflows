---
name: setup
description: Configure doc-sentinel drift detection for a project — detect docs root, watched files, and ignore patterns
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, Write, Edit
---

# doc-sentinel:setup

Interactive setup wizard that creates `.doc-sentinel.json` configuration.

## Phase 1: Detect Project Layout

Run these commands to understand the project:

```bash
# Project structure
ls -la
ls docs/ 2>/dev/null || echo "No docs/ directory"

# Top-level doc files
for f in AGENTS.md ARCHITECTURE.md CLAUDE.md README.md CHANGELOG.md; do
  [ -f "$f" ] && echo "Found: $f"
done

# Check for existing config
cat .doc-sentinel.json 2>/dev/null || echo "No existing config"

# Check for companion plugins
cat .doc-sync.json 2>/dev/null && echo "doc-sync detected"
cat .inkwell.json 2>/dev/null && echo "inkwell detected"
```

## Phase 2: Discover Documentation Files

```bash
# Find all markdown docs
find . -name '*.md' -not -path './node_modules/*' -not -path './.git/*' | head -50

# Find source directories
ls -d src/ lib/ app/ packages/ */ 2>/dev/null | head -20
```

## Phase 3: Configure

Build `.doc-sentinel.json` interactively. Present detected values and ask for confirmation.

### Configuration Schema

```json
{
  "version": 1,
  "docs_root": "docs",
  "watch_files": [
    "AGENTS.md",
    "ARCHITECTURE.md",
    "README.md"
  ],
  "ignore_sources": [
    "*.test.*",
    "*.spec.*",
    "__tests__/**",
    "*.d.ts"
  ],
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

**Fields:**

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `version` | number | `1` | Config schema version |
| `docs_root` | string | `"docs"` | Primary documentation directory |
| `watch_files` | string[] | `["AGENTS.md", "ARCHITECTURE.md", "README.md"]` | Additional doc files outside docs_root to monitor |
| `ignore_sources` | string[] | `["*.test.*", "*.spec.*", "__tests__/**", "*.d.ts"]` | Source file patterns to skip during drift detection |
| `ignore_docs` | string[] | `[]` | Doc files to exclude from drift checks |
| `severity` | object | see below | Drift severity by doc category |

**Severity levels:** `high` (flag immediately), `medium` (flag at session end), `low` (include in scan reports only).

Default severity:
- `architecture` → high (ARCHITECTURE.md references are critical)
- `agents_md` → high (AGENTS.md/CLAUDE.md references are critical)
- `api_reference` → medium
- `changelog` → low (changelogs are append-only, rarely drift)
- `readme` → medium

## Phase 4: Integration Check

If doc-sync or inkwell config exists, note the relationship:

> doc-sentinel complements doc-sync/inkwell. They write docs; sentinel catches when those docs drift from reality. No conflicts — they use separate queue files.

## Phase 5: Write Configuration

Write `.doc-sentinel.json` to the project root.

Recommend adding to `.gitignore`:

```
.doc-sentinel-drift.json
```

The drift file is ephemeral (session-scoped warnings). The config file should be committed.

## Phase 6: Confirm

Print summary:

```
doc-sentinel configured:
  Docs root:      docs/
  Watched files:  AGENTS.md, ARCHITECTURE.md, README.md
  Ignore sources: *.test.*, *.spec.*, __tests__/**, *.d.ts
  Severity:       2 high, 2 medium, 1 low

Hooks will detect drift on every commit. Run /doc-sentinel:scan for a baseline report.
```
