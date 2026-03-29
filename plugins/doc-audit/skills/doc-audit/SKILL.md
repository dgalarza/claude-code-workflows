---
name: doc-audit
description: Audit codebase documentation for accuracy, completeness, and freshness. Compares docs against actual code structure, auto-fixes small discrepancies, reports structural changes. Works with any language/framework. Companion to agent-ready.
---

# Doc Audit

Audit and maintain the documentation artifacts that make a codebase legible to AI agents. This skill is the **maintenance companion** to agent-ready -- agent-ready scaffolds docs, doc-audit keeps them accurate.

---

## Mode Detection

Determine which mode to run based on user intent:

| User Intent | Mode | Trigger Phrases |
|-------------|------|-----------------|
| Check docs health | **audit** | "audit docs", "check documentation", "are docs up to date" |
| Fix issues | **fix** | "fix docs", "update documentation", "sync docs" |
| Full analysis + roadmap | **full** | "full doc audit", "doc audit with roadmap" |

If intent is ambiguous, default to **audit** mode (read-only, safe).

---

## Mode: audit (default, read-only)

No files are modified. Produces a report of findings.

### Step 1: Reconnaissance

Gather codebase metadata for comparison against documentation.

Check if `scripts/recon.sh` exists relative to this skill's plugin directory. If available, run it. Otherwise, run equivalent inline commands:

```bash
# Project type detection
for f in package.json Gemfile requirements.txt pyproject.toml go.mod Cargo.toml build.sbt pom.xml *.csproj; do
    [ -f "$f" ] && echo "Found: $f"
done

# Find all documentation files
find . -maxdepth 3 \( -name "AGENTS.md" -o -name "CLAUDE.md" -o -name "ARCHITECTURE.md" -o -name "README.md" -o -name "CONTRIBUTING.md" \) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | sort

# Docs directory contents
find docs/ doc/ -type f -name "*.md" 2>/dev/null | sort || echo "No docs/ directory"

# ADRs
find . -path "*/decisions/*.md" -o -path "*/adr/*.md" -o -path "*/adrs/*.md" 2>/dev/null | grep -v node_modules | grep -v .git | sort || echo "No ADRs found"

# Top-level structure
ls -1d */ 2>/dev/null | head -20

# Source files
find . -maxdepth 4 -type f \( -name "*.ts" -o -name "*.js" -o -name "*.rb" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rs" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/vendor/*" 2>/dev/null | head -30

# Entry points
ls -1 src/index.* src/main.* app/main.* main.* cmd/ 2>/dev/null || echo "No standard entry points"

# Config files
ls -1 docker-compose.yml docker-compose.yaml Dockerfile .env.example .env.sample turbo.json nx.json lerna.json 2>/dev/null || echo "No config files"

# Recent git changes
git log --since="7 days ago" --name-only --pretty=format:"" 2>/dev/null | sort -u | head -20 || echo "No git history"
```

Determine project pattern:
- If `turbo.json`, `nx.json`, `lerna.json`, `pnpm-workspace.yaml`, or `package.json` with `"workspaces"` exists, load `references/patterns/monorepo.md`
- Otherwise, load `references/patterns/single-package.md`

### Step 2: Assess Each Dimension

Read each dimension reference file for assessment criteria, then evaluate:

**Completeness** -- Read `references/dimensions/completeness.md`
- Are expected documentation artifacts present?
- Does the entry point doc (AGENTS.md/CLAUDE.md) have meaningful content?
- Is there an ARCHITECTURE.md with a codemap?
- Do docs/ and ADRs exist?
- For monorepos: is each package documented?

**Accuracy** -- Read `references/dimensions/accuracy.md`
- Do file paths in ARCHITECTURE.md codemap exist on disk?
- Do port numbers in docs match docker-compose.yml and .env?
- Do build/test/run commands match actual scripts in package.json/Makefile?
- Do dependency and technology references match reality?
- For AI projects: do agent/tool tables match actual definitions?

```bash
# Verify file paths from ARCHITECTURE.md
if [ -f ARCHITECTURE.md ]; then
    grep -oE '`[^`]+/[^`]*`' ARCHITECTURE.md 2>/dev/null | tr -d '`' | while read -r path; do
        [ ! -e "$path" ] && echo "MISSING: $path"
    done
fi

# Compare ports
grep -oE '[0-9]{4,5}' docker-compose.yml 2>/dev/null | sort -u > /tmp/ports_config 2>/dev/null
grep -oE '[0-9]{4,5}' AGENTS.md ARCHITECTURE.md 2>/dev/null | sort -u > /tmp/ports_docs 2>/dev/null
diff /tmp/ports_config /tmp/ports_docs 2>/dev/null || true
```

**Freshness** -- Read `references/dimensions/freshness.md`
- When were docs last modified vs code?
- Are there recent commits that added features without doc updates?
- When was the last ADR written relative to last significant change?
- Are there TODO/FIXME markers in documentation?

```bash
# Doc freshness
for f in AGENTS.md CLAUDE.md ARCHITECTURE.md; do
    [ -f "$f" ] && echo "$f: $(git log -1 --format='%ai (%ar)' -- "$f" 2>/dev/null || echo 'untracked')"
done

# Code activity
echo "Last commit: $(git log -1 --format='%ai (%ar)' 2>/dev/null)"
echo "Commits (30d): $(git rev-list --count --since='30 days ago' HEAD 2>/dev/null)"

# New files without doc updates
git log --since="30 days ago" --diff-filter=A --name-only --pretty=format:"" 2>/dev/null | grep -v '\.md$' | sort -u | head -20

# TODOs in docs
grep -rn 'TODO\|FIXME\|HACK\|XXX' AGENTS.md ARCHITECTURE.md docs/ 2>/dev/null
```

**Coherence** -- Read `references/dimensions/coherence.md`
- Are there broken markdown links between docs?
- Is content duplicated across multiple files?
- Do different docs give conflicting instructions?
- Is CLAUDE.md a proper symlink to AGENTS.md?

```bash
# Broken links
for doc in $(find . -maxdepth 3 -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null); do
    grep -oE '\[.*\]\([^)]+\.md[^)]*\)' "$doc" 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' | sed 's/#.*//' | while read -r ref; do
        dir=$(dirname "$doc")
        target="$dir/$ref"
        [ ! -f "$target" ] && [ ! -f "$ref" ] && echo "BROKEN in $doc: $ref"
    done
done

# CLAUDE.md symlink check
if [ -L CLAUDE.md ]; then
    echo "CLAUDE.md -> $(readlink CLAUDE.md)"
elif [ -f CLAUDE.md ] && [ -f AGENTS.md ]; then
    echo "WARNING: CLAUDE.md and AGENTS.md both exist as regular files"
fi

# Conflicting commands
for doc in AGENTS.md CLAUDE.md README.md CONTRIBUTING.md; do
    [ -f "$doc" ] && echo "--- $doc ---" && grep -E '(npm |yarn |pnpm |bundle |pip |cargo |go |make )' "$doc" 2>/dev/null | head -5
done
```

### Step 3: Generate Report

Read `assets/audit-report-template.md` for the output format.

Categorize each finding:
- **Critical** -- Docs actively mislead (wrong paths, wrong commands, contradictory instructions)
- **Warning** -- Stale or incomplete (missing artifacts, outdated counts, broken links)
- **Info** -- Minor issues (slight description drift, minor duplication, nice-to-have docs missing)

Present the report with specific file paths and line numbers where possible. Include concrete evidence for each finding.

---

## Mode: fix (makes changes)

Runs the full audit, then auto-fixes safe issues and reports the rest.

### Steps 1-3: Run Full Audit

Execute all steps from audit mode to identify issues.

### Step 4: Auto-Fix Small Issues

Apply safe, mechanical fixes that don't require human judgment:

- **Update file paths** in ARCHITECTURE.md codemap that have moved (when the new location is unambiguous)
- **Add missing files/directories** to ARCHITECTURE.md codemap (new packages, new source directories)
- **Remove references** to deleted files/directories from codemap
- **Update port numbers** when docker-compose.yml or .env clearly shows a different port than docs
- **Update environment variable names** when code clearly uses a different name than docs
- **Add new ADRs** to docs/README.md index if they exist on disk but aren't listed
- **Fix broken relative links** between docs when the target file has been moved (not deleted)
- **Update counts** in tables (agent count, tool count, package count) when actual count differs

For each auto-fix:
1. State what is being changed and why
2. Show the before/after
3. Make the edit

### Step 5: Report Remaining Issues

Present issues that require human judgment:
- Structural changes that need rewriting (e.g., new architecture patterns)
- Outdated sections where the correct content isn't clear from code alone
- Missing documentation for new features that need domain knowledge
- Conventions documented that may no longer be followed
- Sections that should be split, merged, or reorganized

### Step 6: Commit Auto-Fixes

Stage and commit all documentation changes:

```bash
git add -A docs/ AGENTS.md ARCHITECTURE.md CLAUDE.md README.md
git commit -m "doc-audit: [summary of fixes]"
```

The commit message should summarize what was fixed (e.g., "doc-audit: update codemap paths, fix port numbers, add missing ADR to index").

---

## Mode: full (fix + roadmap)

Runs the full fix workflow, then generates an improvement roadmap.

### Steps 1-6: Run Full Fix

Execute all steps from fix mode.

### Step 7: Generate Improvement Roadmap

Based on the audit findings and codebase analysis, produce a prioritized improvement plan:

**Priority 1 -- Accuracy fixes** (misleading docs)
- List specific sections that need rewriting with context on what changed in the code

**Priority 2 -- Coverage gaps** (missing docs)
- Suggest new documentation artifacts (nested AGENTS.md, new guides, DOMAIN.md)
- Recommend specific ADRs for decisions that were made but not recorded

**Priority 3 -- Structural improvements** (better organization)
- Recommend splitting large docs into focused files
- Suggest adding guides for common workflows
- Propose docs/ restructuring if the current layout doesn't match the project's needs

**Priority 4 -- Process improvements** (prevent future drift)
- Suggest CI checks for doc freshness
- Recommend doc update triggers (e.g., "update docs when adding a new package")
- Propose periodic doc-audit cadence

Present the roadmap as a numbered, actionable list. Each item should be specific enough that someone (human or agent) could pick it up and execute it.
