---
name: agent-ready
description: Make a codebase agent-ready by scaffolding AGENTS.md, ARCHITECTURE.md, and docs/ structure. Analyzes codebase structure, generates documentation artifacts following progressive disclosure patterns, and audits existing artifacts for staleness and coherence. Use when improving a codebase for AI agent work.
---

# Agent-Ready

Scaffold the documentation and structural artifacts that make a codebase legible to AI agents. This skill is the **remediation companion** to codebase-readiness -- it does not score, it builds.

---

## Startup: Check for Prior Assessment

Before entering any mode, check if `AGENT_READY_ASSESSMENT.md` exists in the project root.

If it exists:
1. Read it and extract dimension scores
2. Auto-suggest a mode based on the weakest dimensions:
   - Documentation & Context < 50 -> suggest **claude-md** first
   - Architecture Clarity < 50 -> suggest **architecture** first
   - Both < 50 -> suggest **scaffold** (full setup)
3. Tell the user: "I found an existing assessment. Based on your scores, I recommend starting with [mode]. Want to proceed, or choose a different mode?"

If it does not exist, proceed with mode detection.

---

## Mode Detection

Determine which mode to run based on user intent:

| User Intent | Mode | Trigger Phrases |
|-------------|------|-----------------|
| Full documentation setup | **scaffold** | "make this agent-ready", "full setup", "scaffold docs" |
| Generate architecture doc | **architecture** | "create ARCHITECTURE.md", "architecture doc", "codemap" |
| Create/refactor AGENTS.md | **agents-md** | "set up AGENTS.md", "create AGENTS.md", "refactor AGENTS.md" |
| Check existing artifacts | **audit** | "audit docs", "are my docs up to date", "check agent readiness" |

If intent is ambiguous, ask the user which mode they want.

---

## Mode: scaffold

Full documentation setup. This is the comprehensive mode that creates everything a codebase needs for agent legibility.

### Step 1: Reconnaissance

Gather project metadata:

```bash
# Language and framework detection
ls package.json Gemfile requirements*.txt pyproject.toml go.mod Cargo.toml build.sbt pom.xml *.csproj 2>/dev/null

# Directory structure
find . -maxdepth 3 -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v vendor | grep -v ".bundle" | grep -v __pycache__ | sort | head -50

# Existing documentation
find . -maxdepth 2 -name "AGENTS.md" -o -name "CLAUDE.md" -o -name "ARCHITECTURE.md" -o -name "README.md" -o -name "CONTRIBUTING.md" 2>/dev/null | grep -v node_modules | grep -v .git
ls -la docs/ doc/ 2>/dev/null
find docs/ doc/ -name "*.md" 2>/dev/null | head -20

# Build/test/lint commands
cat package.json 2>/dev/null | grep -A5 '"scripts"'
cat Makefile 2>/dev/null | grep -E "^[a-zA-Z_-]+:" | head -10
cat Rakefile 2>/dev/null | head -20
ls .eslintrc* .rubocop.yml .prettierrc* pyproject.toml ruff.toml .golangci.yml 2>/dev/null

# CI configuration
ls .github/workflows/*.yml .circleci/config.yml .buildkite/*.yml Jenkinsfile 2>/dev/null

# ADRs
find . -type d -name "decisions" -o -name "adr" -o -name "adrs" 2>/dev/null | grep -v node_modules | grep -v .git
```

### Step 2: Report Inventory

Present a clear inventory to the user:

```
## Documentation Inventory

### Exists
- [List each existing artifact with path and line count]

### Missing
- [List each missing artifact that will be created]

### Will Create
- docs/ directory structure
- docs/README.md (documentation index)
- ARCHITECTURE.md (codemap, invariants, boundaries)
- AGENTS.md (progressive disclosure entry point)
- CLAUDE.md (symlink to AGENTS.md for Claude Code compatibility)
- docs/decisions/001-agent-ready-documentation.md (starter ADR)
```

### Step 3: Create docs/ Structure

Read `assets/docs-structure-template.md` for the recommended layout.

Create the directory structure:
```bash
mkdir -p docs/architecture docs/guides docs/references docs/decisions
```

Create `docs/README.md` as an index. Populate it based on what documentation exists and what will be created.

### Step 4: Generate ARCHITECTURE.md

Execute the **architecture** mode logic (see below) inline. Do not launch a separate agent.

### Step 5: Generate AGENTS.md

Execute the **agents-md** mode logic (see below) inline. Do not launch a separate agent.

### Step 6: Create Starter ADR

Create `docs/decisions/001-agent-ready-documentation.md`:

```markdown
# 1. Agent-Ready Documentation Structure

**Date:** [today's date]
**Status:** Accepted

## Context
This codebase is being prepared for AI agent work. Agents need structured, discoverable documentation to work effectively -- they cannot access knowledge that lives outside the repository.

## Decision
Adopt a progressive disclosure documentation structure:
- AGENTS.md as a concise entry point (~100 lines) with markdown links to detailed docs
- CLAUDE.md as a symlink to AGENTS.md for Claude Code compatibility
- ARCHITECTURE.md as a codemap with invariants and boundaries
- docs/ directory for guides, references, and decision records
- Nested AGENTS.md files for major domain directories (as needed)

## Consequences
- All project knowledge must live in-repo (not in Slack, Confluence, or heads)
- Documentation changes should be reviewed like code changes
- AGENTS.md must stay concise; bloat gets extracted to docs/
- ADRs should be written for significant architectural decisions going forward

## Alternatives Considered
- Single large AGENTS.md -- rejected because it crowds agent context and rots quickly
- No structured docs, rely on code comments -- rejected because agents need navigational aids beyond inline comments
```

### Step 7: Summary

Present everything created with file paths, and suggest next steps:
- Add domain-specific nested AGENTS.md files for major directories
- Start writing ADRs for future architectural decisions
- Set up CI checks for documentation freshness
- Run `agent-ready audit` periodically to check for drift

---

## Mode: architecture

Generate an ARCHITECTURE.md from actual codebase analysis.

### Step 1: Map the Codebase

```bash
# Top-level structure
find . -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v vendor | grep -v ".bundle" | grep -v __pycache__ | sort

# Identify major modules and entry points
find . -maxdepth 2 -type f -name "*.ts" -o -name "*.js" -o -name "*.rb" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.scala" 2>/dev/null | grep -v node_modules | grep -v .git | grep -v vendor | head -50

# Entry points
ls src/index.* src/main.* app/main.* main.* cmd/ 2>/dev/null
ls config/ 2>/dev/null

# Largest files (potential god objects)
find . -name "*.ts" -o -name "*.js" -o -name "*.rb" -o -name "*.py" -o -name "*.go" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test \
  | xargs wc -l 2>/dev/null | sort -rn | head -15
```

### Step 2: Detect Patterns

Read source files to identify:
- **Layers:** controllers/handlers, services, repositories/models, utilities
- **Domains:** distinct business domains grouped in the filesystem
- **Entry points:** where the application starts, what the main interfaces are
- **Configuration:** how the app is configured, environment handling
- **Cross-cutting:** logging, auth, error handling, middleware

### Step 3: Read Existing Context

Read README.md and any existing documentation for project context. Do not duplicate what README already covers -- ARCHITECTURE.md complements it.

### Step 4: Load References

Read `references/architecture-guide.md` for matklad's principles.
Read `assets/architecture-md-template.md` for the output template.

### Step 5: Generate ARCHITECTURE.md

Using the template and principles, generate an ARCHITECTURE.md with:
- **Overview:** One paragraph describing the problem domain (not the tech stack)
- **Codemap:** Every significant top-level directory with one-line descriptions. Name important files and types.
- **Invariants:** Rules that hold across the codebase. **Always include absences** -- things that deliberately do not exist.
- **Boundaries:** Public vs internal APIs. Layer dependency rules. Which modules can import which.
- **Cross-cutting concerns:** How logging, auth, errors, and config work across the system.

### Step 6: Present and Confirm

Show the draft to the user. Write to `ARCHITECTURE.md` in the project root on confirmation.

---

## Mode: agents-md

Create a new AGENTS.md or refactor an existing one for progressive disclosure. Also creates CLAUDE.md as a symlink for Claude Code compatibility.

### Step 1: Assess Current State

Check if AGENTS.md or CLAUDE.md exists:

```bash
find . -name "AGENTS.md" -o -name "CLAUDE.md" 2>/dev/null | grep -v node_modules | grep -v .git
```

**If AGENTS.md exists**, analyze it:
```bash
wc -l AGENTS.md
# Code block percentage
echo "Code block lines: $(sed -n '/^```/,/^```/p' AGENTS.md | wc -l)"
# Directive density
echo "Directive keywords: $(grep -ci 'must\|never\|always\|avoid\|prefer' AGENTS.md)"
# Doc links
echo "Doc links: $(grep -coE '\[.*\]\([^)]+\.md\)' AGENTS.md)"
# Section count
echo "Sections: $(grep -c '^##' AGENTS.md)"
```

Read the existing AGENTS.md fully. Identify:
- Sections that are bloated (>30 lines on one topic)
- Code examples that are too long (>10 lines)
- Content that belongs in topic docs, not AGENTS.md
- Missing directives (build, test, lint commands)
- Missing links to supporting docs

**If CLAUDE.md exists but not AGENTS.md**, analyze CLAUDE.md the same way and plan to migrate it to AGENTS.md.

**If neither exists**, proceed to generation.

### Step 2: Load References

Read `references/progressive-disclosure.md` for Harness Engineering principles.
Read `assets/claude-md-template.md` for the output template (note: template is called claude-md-template but generates AGENTS.md content).

### Step 3: Detect Project Signals

Gather the information needed to populate AGENTS.md:

```bash
# Build/test/lint commands
cat package.json 2>/dev/null | grep -A10 '"scripts"'
cat Makefile 2>/dev/null | grep -E "^[a-zA-Z_-]+:" | head -10
ls .eslintrc* .rubocop.yml .prettierrc* ruff.toml .golangci.yml 2>/dev/null

# CI config (for workflow hints)
ls .github/workflows/*.yml 2>/dev/null

# Existing docs to link
find docs/ doc/ -name "*.md" 2>/dev/null | head -20
ls ARCHITECTURE.md CONTRIBUTING.md 2>/dev/null
```

### Step 4: Generate or Refactor

**New AGENTS.md:**
Using the template, generate an AGENTS.md that:
- Stays under ~100 lines
- Leads with project identity and build/test/lint one-liners
- Uses directives (must/never/always/avoid/prefer) for conventions
- Markdown links to existing docs or docs that should be created
- Lists max 5 known gotchas
- Avoids code examples longer than 5 lines

**Refactoring existing AGENTS.md or migrating from CLAUDE.md:**
1. Identify bloated sections
2. Extract content to appropriate docs/ files (create them)
3. Replace extracted content with markdown links
4. Tighten language to directives
5. Present before/after comparison showing:
   - Line count reduction
   - Content moved to which files
   - New doc links added

### Step 5: Create Symlink

After creating or updating AGENTS.md, create a symlink from CLAUDE.md to AGENTS.md for Claude Code compatibility:

```bash
# Remove CLAUDE.md if it exists and is a regular file (not already a symlink)
if [ -f CLAUDE.md ] && [ ! -L CLAUDE.md ]; then
  # If CLAUDE.md exists and AGENTS.md doesn't exist yet, this was already migrated in step 4
  # Otherwise, back it up first
  if [ ! -f AGENTS.md ]; then
    echo "CLAUDE.md will be migrated to AGENTS.md"
  else
    echo "Backing up existing CLAUDE.md to CLAUDE.md.backup before creating symlink"
    mv CLAUDE.md CLAUDE.md.backup
  fi
fi

# Create the symlink
ln -sf AGENTS.md CLAUDE.md

# Verify the symlink
ls -la CLAUDE.md
```

Inform the user that:
- AGENTS.md is the canonical documentation file that works with any AI coding agent
- CLAUDE.md is a symlink to AGENTS.md for backward compatibility with Claude Code
- Both files now point to the same content

### Step 6: Present and Confirm

Show the draft (or before/after diff for refactoring). Write AGENTS.md and create the CLAUDE.md symlink on confirmation.

---

## Mode: audit

Check health of existing agent-readiness artifacts.

### Step 1: Inventory

Find all agent-readiness artifacts:

```bash
# AGENTS.md and CLAUDE.md files (root and nested)
find . -name "AGENTS.md" -o -name "CLAUDE.md" 2>/dev/null | grep -v node_modules | grep -v .git

# Check if CLAUDE.md is a symlink to AGENTS.md
if [ -L CLAUDE.md ]; then
  echo "CLAUDE.md is a symlink to: $(readlink CLAUDE.md)"
fi

# ARCHITECTURE.md
find . -name "ARCHITECTURE.md" 2>/dev/null | grep -v node_modules | grep -v .git

# docs/ contents
find docs/ doc/ -type f 2>/dev/null | grep -v node_modules | grep -v .git

# ADRs
find . -path "*/decisions/*.md" -o -path "*/adr/*.md" -o -path "*/adrs/*.md" 2>/dev/null | grep -v node_modules | grep -v .git
```

### Step 2: Staleness Checks

**ARCHITECTURE.md vs actual structure:**
- Read ARCHITECTURE.md and extract mentioned directories/modules
- Compare against actual directory tree
- Flag directories mentioned in ARCHITECTURE.md that no longer exist
- Flag significant directories that exist but are not mentioned

**Linked doc resolution:**
```bash
# Check both AGENTS.md and CLAUDE.md for broken links
for doc in AGENTS.md CLAUDE.md; do
  if [ -f "$doc" ]; then
    grep -oE '\[.*\]\([^)]+\.md\)' "$doc" 2>/dev/null | grep -oE '\([^)]+\)' | tr -d '()' | while read -r ref; do
      if [ ! -f "$ref" ]; then
        echo "BROKEN in $doc: $ref not found"
      fi
    done
  fi
done
```

**ADR recency:**
```bash
find . -path "*/decisions/*.md" -o -path "*/adr/*.md" 2>/dev/null | grep -v node_modules | xargs ls -lt 2>/dev/null | head -5
```

### Step 3: Coherence Checks

Run the coherence analysis from the codebase-readiness documentation dimension:

```bash
# AGENTS.md content type analysis (use AGENTS.md as primary, fall back to CLAUDE.md if it's not a symlink)
DOC="AGENTS.md"
if [ ! -f "$DOC" ] && [ -f "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ]; then
  DOC="CLAUDE.md"
fi

if [ -f "$DOC" ]; then
  echo "Analyzing: $DOC"
  echo "Total lines: $(wc -l < "$DOC")"
  echo "Code block lines: $(sed -n '/^```/,/^```/p' "$DOC" | wc -l)"
  echo "Directive keywords (must/never/always/avoid/prefer): $(grep -ci 'must\|never\|always\|avoid\|prefer' "$DOC")"
  TOTAL=$(wc -l < "$DOC")
  CODE=$(sed -n '/^```/,/^```/p' "$DOC" | wc -l)
  if [ "$TOTAL" -gt 0 ]; then
    PCT=$(( CODE * 100 / TOTAL ))
    echo "Code example percentage: ${PCT}%"
  fi
fi

# Check symlink status
if [ -L CLAUDE.md ]; then
  echo "✓ CLAUDE.md is correctly symlinked to $(readlink CLAUDE.md)"
elif [ -f CLAUDE.md ] && [ -f AGENTS.md ]; then
  echo "⚠ WARNING: Both CLAUDE.md and AGENTS.md exist as separate files. CLAUDE.md should be a symlink to AGENTS.md"
fi

# Topic overlap
DOC="AGENTS.md"
if [ ! -f "$DOC" ] && [ -f "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ]; then
  DOC="CLAUDE.md"
fi

for doc in $(find docs/ doc/ -name "*.md" -maxdepth 2 2>/dev/null | grep -v node_modules); do
  TOPIC=$(basename "$doc" .md | tr '[:upper:]' '[:lower:]' | sed 's/_/ /g')
  if [ -f "$DOC" ] && grep -qi "$TOPIC" "$DOC" 2>/dev/null; then
    DOC_MENTIONS=$(grep -ci "$TOPIC" "$DOC" 2>/dev/null)
    DOC_LINES=$(wc -l < "$doc" 2>/dev/null | tr -d ' ')
    echo "Overlap: '$TOPIC' -- $DOC mentions ${DOC_MENTIONS}x, dedicated doc is ${DOC_LINES} lines"
  fi
done

# Broken references
if [ -f "$DOC" ]; then
  grep -oE '\[.*\]\(\./[^)]+\)' "$DOC" 2>/dev/null | grep -oE '\./[^)]+' | while read -r ref; do
    if [ ! -f "$ref" ]; then
      echo "BROKEN link in $DOC: $ref not found"
    fi
  done
fi

# Source of truth declarations
find AGENTS.md CLAUDE.md docs/ -type f 2>/dev/null | xargs grep -rn "source of truth\|authoritative\|canonical\|definitive" 2>/dev/null | grep -v node_modules | grep -v .git
```

### Step 4: Coverage Checks

- **Domain directories without nested AGENTS.md:** Find major source directories that could benefit from domain-specific AGENTS.md files
- **Unlisted directories in ARCHITECTURE.md:** Find top-level source directories not mentioned in the codemap
- **Missing docs/ categories:** Check if guides/, references/, decisions/ exist and have content

### Step 5: Report

Present an actionable report:

```
## Agent-Readiness Audit

### Artifact Inventory
| Artifact | Status | Location | Lines |
|----------|--------|----------|-------|
| AGENTS.md (root) | [Present/Missing] | ./AGENTS.md | [N] |
| CLAUDE.md (symlink) | [Correct symlink/Regular file/Missing] | ./CLAUDE.md | — |
| ARCHITECTURE.md | [Present/Missing] | ./ARCHITECTURE.md | [N] |
| docs/ index | [Present/Missing] | ./docs/README.md | [N] |
| ADRs | [N found] | ./docs/decisions/ | — |
| Nested AGENTS.md | [N found] | [locations] | — |

### Staleness Issues
- [List stale items with specific file paths and what's wrong]

### Coherence Issues
- Primary doc (AGENTS.md or CLAUDE.md) line count: [N] [OK if <150 / WARNING if >150 / CRITICAL if >300]
- Code example %: [N]% [OK if <20% / WARNING if >20%]
- Directive density: [N] directives in [M] lines
- CLAUDE.md symlink status: [Correct/Needs fix]
- Topic overlaps: [list]
- Broken references: [list]
- Cross-document conflicts: [list]

### Coverage Gaps
- Directories without AGENTS.md: [list]
- Directories not in ARCHITECTURE.md: [list]
- Missing docs/ categories: [list]

### Recommended Actions
1. [Highest priority fix -- specific, actionable]
2. [Second priority fix]
3. [Third priority fix]
```

After presenting the report, offer to auto-fix issues:
- Broken doc links: remove or create the missing file
- Primary doc bloat: offer to run agents-md mode to refactor
- Missing ARCHITECTURE.md entries: offer to run architecture mode to regenerate
- Missing nested AGENTS.md: offer to create starter files for uncovered domains
- CLAUDE.md not a symlink: offer to convert it to a symlink to AGENTS.md
