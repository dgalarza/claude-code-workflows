---
name: scan
description: Full-codebase documentation drift scan — find every doc that references code reality incorrectly
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep
---

# doc-sentinel:scan

Deep scan that cross-references all documentation against the current state of the codebase. Unlike the hook (which checks only files changed in a commit), this scans everything.

This skill is **read-only** — it reports drift but does not modify files.

## Phase 1: Load Configuration

```bash
cat .doc-sentinel.json 2>/dev/null || echo "No config — using defaults"
```

Defaults if no config:
- `docs_root`: `docs`
- `watch_files`: `AGENTS.md`, `ARCHITECTURE.md`, `README.md`, `CLAUDE.md`
- `ignore_sources`: `*.test.*`, `*.spec.*`, `__tests__/**`

## Phase 2: Discover Documentation

Collect all doc files:

```bash
# docs/ directory
find docs/ -name '*.md' -type f 2>/dev/null | sort

# Top-level docs
for f in AGENTS.md ARCHITECTURE.md CLAUDE.md README.md CHANGELOG.md; do
  [ -f "$f" ] && echo "$f"
done
```

Plus any `watch_files` from config.

## Phase 3: Extract References

For each doc file, extract references to source code:

### 3a: File Path References

Search for paths that look like source file references:

```bash
# Extract paths from backticks, links, and code blocks
grep -oE '`[a-zA-Z0-9_./-]+\.(ts|js|py|rb|go|rs|java|tsx|jsx)`' "$doc_file"
grep -oE '\b(src|lib|app|packages)/[a-zA-Z0-9_./-]+' "$doc_file"
```

### 3b: Command References

Extract shell commands documented in the file:

```bash
# Find code blocks with shell commands
grep -E '^\$|^pnpm |^npm |^yarn |^cargo |^go |^bundle |^python |^make ' "$doc_file"
```

### 3c: Port and URL References

```bash
grep -oE '(localhost|127\.0\.0\.1):[0-9]+' "$doc_file"
grep -oE ':[0-9]{4,5}\b' "$doc_file"
```

### 3d: Environment Variable References

```bash
grep -oE '\$\{?[A-Z_][A-Z0-9_]*\}?' "$doc_file"
grep -oE '`[A-Z_][A-Z0-9_]*`' "$doc_file"
```

## Phase 4: Validate References

For each extracted reference, check if it still holds:

### 4a: File Paths — Do They Exist?

```bash
# For each extracted path
[ -f "$path" ] && echo "OK: $path" || echo "DRIFT: $path — file not found"
```

### 4b: Directory References — Do They Exist?

```bash
[ -d "$dir" ] && echo "OK: $dir" || echo "DRIFT: $dir — directory not found"
```

### 4c: Commands — Do They Parse?

For package.json scripts:
```bash
# Check if documented npm/pnpm scripts exist
jq -r '.scripts | keys[]' package.json 2>/dev/null
```

### 4d: Ports — Are They Consistent?

Cross-reference ports mentioned in docs against:
- `docker-compose.yml` / `compose.yml` port mappings
- `.env` / `.env.example` port variables
- Other doc files (detect conflicts between docs)

### 4e: Env Vars — Are They Still Used?

```bash
# Check if documented env vars appear in source
grep -r "$ENV_VAR" src/ lib/ app/ --include='*.ts' --include='*.js' --include='*.py' -l 2>/dev/null
```

### 4f: Symlink Integrity

```bash
# CLAUDE.md should symlink to AGENTS.md (if using agent-ready convention)
[ -L "CLAUDE.md" ] && readlink CLAUDE.md || echo "Not a symlink"
```

## Phase 5: Freshness Analysis

For each doc file, compare modification dates:

```bash
# When was the doc last modified?
git log -1 --format="%ai" -- "$doc_file"

# When were its referenced source files last modified?
git log -1 --format="%ai" -- "$source_file"
```

**Freshness scoring:**

| Score | Label | Criteria |
|-------|-------|----------|
| 0 | Fresh | Doc modified more recently than all referenced sources |
| 1 | Current | Doc modified within 7 days of source changes |
| 2 | Stale | Source changed 7-30 days after doc last updated |
| 3 | Very Stale | Source changed >30 days after doc last updated |

ADR files are exempt from freshness scoring — they are point-in-time records.

## Phase 6: Generate Report

Output a structured drift report organized by severity:

```markdown
# Documentation Drift Report
Generated: YYYY-MM-DD HH:MM

## Critical Drift (broken references)
| Doc | Reference | Issue |
|-----|-----------|-------|
| ARCHITECTURE.md | `src/old-module/` | Directory not found |
| AGENTS.md | `pnpm studio` | Script not in package.json |

## Stale References (code changed, doc not updated)
| Doc | Source File | Doc Last Updated | Source Last Updated | Freshness |
|-----|------------|------------------|---------------------|-----------|
| docs/api.md | src/routes/auth.ts | 2026-01-15 | 2026-04-01 | Very Stale |

## Warnings
| Doc | Issue |
|-----|-------|
| README.md | Port 3000 mentioned but compose.yml maps to 4000 |
| AGENTS.md | Env var `OLD_VAR` not found in source |

## Summary
- X critical drift(s) — broken paths, missing files
- Y stale reference(s) — code changed without doc updates
- Z warning(s) — potential inconsistencies
- N docs scanned, M references checked
```

## Rules

- Never modify any files — this is a read-only scan
- Report concrete evidence (file paths, line numbers, dates) not speculation
- Skip vendored directories (node_modules, vendor, .git)
- Treat CHANGELOG.md as append-only — only flag if it references non-existent versions/tags
- ADRs are exempt from freshness checks
- If a doc file is >500 lines, sample the first 200 and last 100 lines for references
