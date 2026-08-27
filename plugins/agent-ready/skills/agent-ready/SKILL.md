---
name: agent-ready
description: Make a codebase agent-ready by scaffolding AGENTS.md, ARCHITECTURE.md, and docs/ structure, installing regression-aware quality gates, and recommending project-local, stack-specific skills. Analyzes codebase structure, generates documentation artifacts following progressive disclosure patterns, installs report/check/baseline quality-gate commands with merge-base-aware CI and a human-reviewed baseline, and audits existing artifacts for staleness and coherence. Use when improving a codebase for AI agent work.
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
   - Quality gates at L0-L2 in the snapshot (or Code Clarity / Change Safety < 50 with no debt gate in the evidence) -> suggest **quality-gates**
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
| Install regression-aware quality gates | **quality-gates** | "set up quality gates", "block new complexity", "baseline our tech debt", "stop agents adding dead code", "regression gate" |
| Check existing artifacts | **audit** | "audit docs", "are my docs up to date", "check agent readiness" |

If intent is ambiguous, ask the user which mode they want.

---

## Startup: Recommend Project Skills

After selecting a mode and before making project changes, read `references/recommended-skills.md` and inspect the repository for its documented framework signals.

When one or more catalog entries match:
1. Check project-local skills and exclude any that are already installed
2. Present core matches under **Recommended** and qualifying UI matches under **Optional**, with the detected signal, skill, source, and short rationale
3. Ask once whether to install recommended skills only, recommended plus optional skills, a selected subset, or none; do not select optional skills by default
4. Wait for explicit confirmation; never install a skill based only on detection
5. Install confirmed skills from the repository root with the catalog commands, which omit `--global` to preserve project scope
6. Report install results and continue the selected agent-ready mode even if an install fails

When nothing matches or all matching skills are installed, continue without prompting. Do not recommend uncataloged skills merely because they seem related.

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
- docs/DOMAIN.md (business domain knowledge, terminology, workflows)
- AGENTS.md (progressive disclosure entry point)
- CLAUDE.md (symlink to AGENTS.md for Claude Code compatibility)
- docs/decisions/001-agent-ready-documentation.md (starter ADR)
- Quality gate: scripts/quality-gate.py, .quality-gate.json, CI job, docs/guides/quality-gates.md, gate self-test (baseline created only after review -- see Step 8)
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

### Step 5: Generate docs/DOMAIN.md

Read `assets/domain-knowledge-template.md` for the template.

Seed the template by scanning the codebase:

```bash
# Find model/entity/type names
find . -type f \( -name "*.rb" -o -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.java" \) 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor \
  | xargs grep -lE "class |model |entity |type |interface |struct " 2>/dev/null | head -20

# Look for model directories
find . -type d \( -name "models" -o -name "entities" -o -name "types" -o -name "schemas" -o -name "domain" \) 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor

# Read README for business context
cat README.md 2>/dev/null | head -80
```

Using the discovered model/entity names and README context:
1. Populate the glossary with discovered terms, even if definitions are thin -- mark them with `<!-- TODO: needs domain expert review -->`
2. Sketch domain relationships based on model associations or naming patterns
3. Leave workflow and regulatory sections as template placeholders if not enough context exists

Write the result to `docs/DOMAIN.md`. Note in the output that this file should be reviewed and filled in by domain experts on the team -- it is seeded from code analysis and will have gaps.

### Step 6: Generate AGENTS.md

Execute the **agents-md** mode logic (see below) inline. Do not launch a separate agent.

### Step 7: Create Starter ADR

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
- docs/DOMAIN.md for business domain knowledge, terminology, and workflows
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

### Step 8: Install Quality Gates

Execute the **quality-gates** mode logic (see below) inline. The Definition of Done written in Step 6 must reference the gate's `check` command, so if Step 6 ran before the command name was known, update AGENTS.md now.

Do not skip the baseline review protocol to keep scaffold moving: if the user is not ready to review the baseline, install the engine, config, CI, docs, and tests, leave the baseline uncreated, and record in the summary that `check` will fail until a baseline is created and approved.

### Step 9: Summary

Present everything created with file paths, and suggest next steps:
- Review `docs/DOMAIN.md` and add business domain definitions -- this is the most valuable file for human and AI onboarding
- Add domain-specific nested AGENTS.md files for major directories
- Start writing ADRs for future architectural decisions
- Set up CI checks for documentation freshness
- Review and approve the quality-gate baseline PR, then add `.quality-baseline.json` to CODEOWNERS
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
Read `assets/agent-ready-template.md` for the output template that generates AGENTS.md content.

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

# ADRs (check if decision records exist)
find . -path "*/decisions/*.md" -o -path "*/adr/*.md" -o -path "*/adrs/*.md" 2>/dev/null | grep -v node_modules | grep -v .git | head -5
```

### Step 4: Generate or Refactor

**New AGENTS.md:**
Using the template, generate an AGENTS.md that:
- Stays under ~120 lines
- Leads with project identity and build/test/lint one-liners
- Includes a **Session Startup** section with the bearing-getting ritual (pwd, git log, fetch origin, sync with the upstream default branch using the repo's merge/rebase strategy, smoke test) -- fill in the smoke-test command from detected scripts, or leave a `[TODO: add smoke-test command]` placeholder if nothing is detected
- Uses directives (must/never/always/avoid/prefer) for conventions
- Includes a **Definition of Done** section codifying end-to-end verification before marking work complete -- fill in lint/test commands from detected tooling, and the quality-gate `check` command if `.quality-gate.json` (or a native gate such as `golangci-lint` with `new-from-merge-base`, `detekt --baseline`, or a PHPStan baseline) exists or is about to be installed by scaffold
- Includes three quality-gate directives (run `check` before finishing; never edit, extend, or approve the baseline; run `baseline --prune` when `check` reports stale entries) under Key Conventions or Definition of Done, not as a new section
- If the repo already uses machine-updated ledgers such as `tasks.json`, status queues, or work trackers, include a directive that names exactly which fields agents may edit
- Markdown links to existing docs or docs that should be created
- Includes ADR section if docs/decisions/ or other ADR directories exist
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

## Mode: quality-gates

Install a regression-aware quality gate: the project's native complexity, duplication, and dead-code checks, a baseline that lets legacy debt stay while new or worsened debt fails, merge-base-aware PR CI, reproducible local commands, docs, and tests of the gate. Read `references/quality-gates-pattern.md` first; it defines the contract and the per-language adapters.

Never run this mode to make a failing gate pass. If a gate exists and `check` is red, fix the code or prune stale entries; do not extend the baseline.

### Step 1: Detect Tools and Existing Gates

```bash
# Language and existing analyzers
ls package.json Gemfile pyproject.toml requirements*.txt go.mod Cargo.toml composer.json pom.xml build.gradle* build.sbt 2>/dev/null
ls .eslintrc* eslint.config.* biome.json .rubocop.yml .rubocop_todo.yml ruff.toml pyproject.toml .pylintrc .golangci.yml phpstan.neon* phpmd*.xml detekt*.yml pmd*.xml knip.json* .jscpd.json 2>/dev/null
grep -E '"(lint|typecheck|test|quality|gate)"' package.json 2>/dev/null

# Existing gate artifacts
ls .quality-gate.json .quality-baseline.json scripts/quality-gate.py scripts/quality-gate-test.sh docs/guides/quality-gates.md 2>/dev/null
grep -E "new-from-rev|new-from-merge-base|reportUnmatchedIgnoredErrors|baseline" .golangci.yml phpstan.neon* detekt*.yml 2>/dev/null
grep -rlE "complexity|jscpd|flay|knip|vulture|debride|gocyclo|dupl|phpmd|detekt|quality-gate" .github/workflows .gitlab-ci.yml .circleci 2>/dev/null

# Hook frameworks and CODEOWNERS
ls .husky lefthook.yml .pre-commit-config.yaml .github/CODEOWNERS CODEOWNERS 2>/dev/null
python3 --version
```

Decide the route from `references/quality-gates-pattern.md`:
- **Option A** when the native tool has a baseline or diff mode (golangci-lint, detekt, PHPStan, RuboCop todo). Prefer it; no custom engine needed.
- **Option B** otherwise: install `assets/quality-gate.py` and write adapters that emit the contract format.

If a partial gate already exists, extend it toward the contract rather than replacing it. Report what exists and what is missing before changing anything.

### Step 2: Choose Checks

Pick three checks -- complexity, duplication, dead code -- from the language's recipes. Use the thresholds the project already configures where they exist; otherwise use the tool's defaults. Do not introduce a new analyzer when the project already runs one that covers the property. Skip a property only when no reliable tool exists for the stack, and say so.

**Run every candidate command by hand** and confirm it emits the contract format (one finding per line, `unix` or `jsonl`). Fix the adapter until it does.

### Step 3: Install Commands

**Option B:**

```bash
mkdir -p scripts
cp "<skill-dir>/assets/quality-gate.py" scripts/quality-gate.py
chmod +x scripts/quality-gate.py
```

Write `.quality-gate.json` with the confirmed checks, `base_ref` set to the repository's default branch (`origin/main` or `origin/master`), and `baseline` at `.quality-baseline.json`. Add `__pycache__/` to `.gitignore` if it is not already ignored.

Adapters that need more than a shell one-liner (JSON reshaping, temp dirs for a reporter) belong in one small script in the project's own language -- for example `scripts/quality-gate-adapter.mjs complexity|duplication|dead-code` -- rather than in the JSON config.

**Both options:** expose `report`, `check`, and `baseline --prune` through the project's task runner so the commands read naturally for the stack -- `make quality-report` / `quality-check`, `npm run quality:check`, `bundle exec rake quality:check`, `just quality-check`. The task-runner entry must call exactly what CI calls.

### Step 4: Report, Then Baseline With Review

```bash
python3 scripts/quality-gate.py report
```

Present the findings grouped by rule and top files. Ask which are cheap enough to fix now -- fixing before baselining is always preferred. Then:

```bash
python3 scripts/quality-gate.py baseline --reason "<user's reason>" --dry-run
```

Show the candidate summary. Only on the user's explicit confirmation run it without `--dry-run`. State clearly that the baseline is written **unreviewed**, that `check` fails until a reviewer runs `baseline --approve --reviewed-by "<name>"`, and that this is by design. Do not run `--approve` on the user's behalf. For Option A tools, the equivalent is committing the generated baseline/todo file in a PR that a named reviewer approves.

If the user declines to baseline now, skip this step; everything else still gets installed and `check` will report the legacy findings as new until a baseline exists.

### Step 5: Wire CI, Hooks, and Protection

- **CI (required):** read `assets/quality-gate-ci-template.yml`; copy to `.github/workflows/quality-gate.yml` (or add the equivalent steps to the existing pipeline for other CI systems). Keep `fetch-depth: 0` and the base-branch fetch so the merge-base resolves. No `continue-on-error`.
- **Hooks (recommended):** if lefthook, husky, or pre-commit exists, add `check --changed-only` as a pre-push step.
- **CODEOWNERS (required):** add `.quality-baseline.json` (or the native baseline file) with a named owner so extending it always needs a human.

### Step 6: Docs and AGENTS.md

- Read `assets/quality-gates-guide-template.md`, fill in the commands, tools, and thresholds, and write `docs/guides/quality-gates.md`. Add it to `docs/README.md`.
- In AGENTS.md: add the `check` command to **Definition of Done**, and add three directives (run `check` before finishing; never edit, extend, or approve the baseline; run `baseline --prune` when `check` reports stale entries). Link the guide from **Common Workflows**. If AGENTS.md does not exist, run agents-md mode.

### Step 7: Tests of the Gate

Copy `assets/quality-gate-test-template.sh` to `scripts/quality-gate-test.sh`. Fill in `FIXTURE_PATH` (a file the complexity check scans that does not exist yet) and `FIXTURE_BODY` (a function over the threshold in the project's language; snippets are in the pattern reference). Run it and confirm all five assertions pass -- the self-test marks its temporary baseline copy as reviewed, so it passes before the real baseline is approved while `check` stays red. Wire it into the project's test command and the CI job.

For Option A, write the equivalent three assertions against the native tool: a clean tree passes, a fixture over the threshold fails, and a regenerated baseline drops a fixed finding.

### Step 8: Summary

```
## Quality Gate Installed

| Check | Tool | Threshold | Findings baselined |
|-------|------|-----------|--------------------|

- Route: [Option A: native <tool> mode / Option B: scripts/quality-gate.py]
- Commands: [report / check / prune, as exposed in the task runner]
- Baseline: [N entries, UNREVIEWED -- approve with ... / not created]
- CI: .github/workflows/quality-gate.yml (merge-base aware, annotates PRs)
- CODEOWNERS: [entry added / TODO]
- Docs: docs/guides/quality-gates.md; AGENTS.md Definition of Done updated
- Tests: scripts/quality-gate-test.sh (5 assertions passing)

Next steps:
- Open a PR with these files; the reviewer inspects the baseline and runs `baseline --approve --reviewed-by "<name>"`
- Fix the cheap findings identified in Step 4 and run `baseline --prune` to lock in the gain
```

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

  # Session Startup section -- bearing-getting ritual for fresh contexts
  if grep -qiE '^##+ .*(session startup|getting (started|up to speed)|orient)' "$DOC"; then
    echo "✓ Session Startup section present"
  else
    echo "⚠ MISSING: Session Startup section -- agents have no prescribed orientation sequence on fresh contexts"
  fi

  # Definition of Done section -- end-to-end verification protocol
  if grep -qiE '^##+ .*(definition of done|verification|done criteria)' "$DOC"; then
    DOD_SECTION=$(awk '
      BEGIN { capture=0 }
      /^##+[[:space:]]/ {
        if (capture) exit
      }
      /^##+[[:space:]].*(Definition of Done|Verification|Done Criteria)/ {
        capture=1
      }
      capture { print }
    ' "$DOC")

    if printf "%s\n" "$DOD_SECTION" | grep -qiE 'end-to-end|end to end|browser|exercise'; then
      echo "✓ Definition of Done section present (mentions end-to-end verification)"
    else
      echo "⚠ Definition of Done section present but does not mention end-to-end verification"
    fi
  else
    echo "⚠ MISSING: Definition of Done section -- no codified end-to-end verification protocol"
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

- **Domain knowledge documentation:** Check if `docs/DOMAIN.md` exists. If it exists, check whether it is populated (has content beyond the template placeholders) or is still a stub. If missing, flag it as a coverage gap with the recommendation: "Create docs/DOMAIN.md to document business domain concepts -- this is the most valuable file for human and AI onboarding."
- **Domain directories without nested AGENTS.md:** Find major source directories that could benefit from domain-specific AGENTS.md files
- **Unlisted directories in ARCHITECTURE.md:** Find top-level source directories not mentioned in the codemap
- **Missing docs/ categories:** Check if guides/, references/, decisions/ exist and have content
- **Quality gate:** Run the detection commands from `references/quality-gates-pattern.md` (`.quality-gate.json`, native baseline/diff modes, CI job, `docs/guides/quality-gates.md`, gate self-test, CODEOWNERS entry, DoD mention). Classify as: **installed and governed** (check in CI, baseline reviewed, self-test present, DoD references it), **installed but ungoverned** (missing review, tests, CODEOWNERS, or DoD mention), **report-only** (tooling runs but cannot fail CI), or **absent**. If `.quality-baseline.json` exists, run `check` and report stale entries and unreviewed status

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
| DOMAIN.md | [Present/Stub/Missing] | ./docs/DOMAIN.md | [N] |
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
- Session Startup section: [Present/Missing]
- Definition of Done section: [Present/Missing/Present-without-E2E]
- Topic overlaps: [list]
- Broken references: [list]
- Cross-document conflicts: [list]

### Coverage Gaps
- Directories without AGENTS.md: [list]
- Directories not in ARCHITECTURE.md: [list]
- Missing docs/ categories: [list]

### Quality Gate
- Status: [installed and governed / installed but ungoverned / report-only / absent]
- Baseline: [N entries, reviewed by X on DATE / unreviewed / none] -- stale entries: [N]
- CI: [blocks on check / continue-on-error / no job]
- Self-test: [present at ... / absent]
- DoD references check command: [yes / no]

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
- Missing Session Startup section: offer to insert the bearing-getting ritual (pwd, git log, fetch origin, sync with the upstream default branch using the repo's merge/rebase strategy, smoke test) using detected commands
- Missing Definition of Done section: offer to insert a DoD checklist using detected lint/test commands
- Quality gate absent or report-only: offer to run quality-gates mode
- Quality gate installed but ungoverned: offer the missing piece only (self-test, CODEOWNERS entry, DoD line, or a reminder that the baseline awaits `--approve`)
- Stale baseline entries: offer to run `baseline --prune` and commit the result
