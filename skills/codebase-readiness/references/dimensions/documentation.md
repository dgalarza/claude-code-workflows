# Documentation

## Why This Matters for Agent Readiness

Documentation is the primary mechanism through which a codebase communicates intent, constraints, and conventions to an AI agent. Without it, the agent must infer architecture from code alone — a process that is slow, error-prone, and misses critical context like "why" decisions were made. Well-structured documentation allows an agent to understand the codebase quickly, respect existing conventions, and avoid repeating mistakes the team has already learned from.

Critically, documentation quality is not just about **presence** — it's about **coherence**. Duplicated or contradictory instructions across multiple docs cause agents to make unpredictable choices about which guidance to follow. A codebase with a well-written CLAUDE.md that contradicts its own TESTING.md is worse than one with a single, shorter CLAUDE.md that delegates clearly.

## What to Examine

### Four Documentation Artifact Types

| Artifact | Purpose | Agent Value |
|----------|---------|-------------|
| **Agent instruction entrypoint** (`AGENTS.md`, `CLAUDE.md`, or a declared equivalent) | Direct instructions to the agent: conventions, gotchas, workflow rules | Highest: agent reads this first |
| **ARCHITECTURE.md** | Structural overview — component map, boundaries, data flow | High — enables navigation without reading all code |
| **ADRs** | Decision records — why choices were made, what alternatives were rejected | High — prevents agent from re-proposing rejected approaches |
| **Topic docs** | Focused guides — CONVENTIONS.md, TESTING.md, DEPLOYMENT.md, etc. | Medium — provides domain-specific depth |

### Agent Instruction Entrypoint Assessment

- **Presence and authority**: Does a root AGENTS.md or CLAUDE.md exist? When both exist, is one explicitly canonical or a symlink rather than a conflicting duplicate?
- **Structure quality**: Is the canonical file well-organized with clear sections, or a wall of text?
- **Imports and links**: Does it reference deeper docs without duplicating content?
- **Bloat anti-pattern**: Is it excessively long (>500 lines)? Bloated instruction files degrade agent performance, so they should be concise and link out to detailed docs.
- **Scoped instructions**: Are nested AGENTS.md or CLAUDE.md files present only where local rules or gotchas justify them?
- **Actionable content**: Does it contain actual instructions (do this, don't do that) vs. just descriptions?
- **Role discipline**: Is it a concise directive index, or has it absorbed tutorial-style content that belongs in topic docs? Signs of role confusion include code examples longer than 10 lines, "how-to" sections with multiple steps, or reference material.

### ARCHITECTURE.md Assessment

- **Codemap presence**: Does it provide a map of the codebase structure — what lives where and why?
- **Component inventory**: Are all major components/services/modules listed with their responsibilities?
- **Invariants**: Are system invariants and constraints documented (e.g., "all API responses must include request_id", "never delete user records — soft delete only")?
- **API boundaries**: Are the boundaries between components documented — what is public API vs. internal?
- **Cross-cutting concerns**: Are concerns that span multiple components documented (auth, logging, error handling)?

### Domain Context and ADR Assessment

- **Glossary authority**: Does `CONTEXT.md` or `CONTEXT-MAP.md` provide canonical business terminology without competing glossaries?
- **Context topology**: Where multiple contexts exist, does the map identify each context and their relationships?
- **Presence**: Do Architecture Decision Records exist when consequential decisions have been made?
- **Quality signals**: Are ADRs concise records of a hard-to-reverse, surprising trade-off, with rationale and alternatives/consequences when useful?
- **Discipline**: Do ADRs avoid routine implementation notes and boilerplate records?
- **Discoverability**: Are ADRs in a standard location (docs/adr/, docs/decisions/, etc.)?

### Topic Documentation Assessment

- **CONVENTIONS.md**: Coding conventions beyond what linters enforce
- **TESTING.md**: Testing philosophy, patterns, how to write tests for this codebase
- **Other topic docs**: DEPLOYMENT.md, API.md, DATABASE.md, etc.

### README Assessment

- **Setup instructions**: Can a new developer (or agent) get a working environment from the README alone?
- **Architecture overview**: Does it provide or link to a high-level architecture description?
- **Contribution guidelines**: Are there clear instructions for how to contribute?

### Documentation Coherence

Documentation quality isn't just about presence — it's about whether docs form a **coherent, non-contradictory system**. Agents that encounter conflicting instructions between CLAUDE.md and topic docs will make unpredictable choices about which to follow. This is one of the most impactful — and most commonly missed — documentation failure modes.

- **Duplication between CLAUDE.md and topic docs**: Does CLAUDE.md inline content that already exists in dedicated docs (e.g., testing patterns duplicated from TESTING.md)? Duplicated content drifts apart over time and creates conflicting instructions. Look for sections in CLAUDE.md that cover topics already addressed by dedicated docs in `docs/`.
- **Source of truth clarity**: When CLAUDE.md and a topic doc both cover the same topic, is it clear which takes precedence? Does CLAUDE.md delegate via @-import, or does it maintain its own competing version? Look for topic docs that declare themselves "authoritative" while CLAUDE.md contains its own rules on the same topic.
- **Cross-document consistency**: Do instructions in CLAUDE.md align with what topic docs, README, and ARCHITECTURE.md say? Look for contradictions in:
  - Recommended patterns (e.g., one doc says "prefer X" while another shows Y as acceptable)
  - Tool/library preferences (e.g., one doc recommends MSW, another shows jest.mock as valid)
  - Naming conventions, file organization, or workflow rules
- **CLAUDE.md role discipline**: Is CLAUDE.md acting as a concise directive index (linking to detailed docs), or has it absorbed tutorial-style content that belongs in topic docs? Measure the ratio of directive lines (containing "must", "never", "always", "avoid", "prefer") to total lines. A healthy CLAUDE.md has a high directive density. Signs of role confusion include:
  - Code examples longer than 10 lines (tutorials belong in topic docs)
  - "How-to" sections with multiple implementation steps
  - Reference material like API inventories or module lists
  - Sections that exceed 30 lines on a single topic

### Documentation CI Enforcement

- **Link checking**: Are documentation links verified in CI?
- **Freshness checks**: Are there mechanisms to detect stale documentation?

## Evidence-Gathering Commands

```bash
# Agent instruction entrypoints and structure
find . \( -name "AGENTS.md" -o -name "CLAUDE.md" \) 2>/dev/null | grep -v node_modules | grep -v .git
wc -l AGENTS.md CLAUDE.md 2>/dev/null
[ -L CLAUDE.md ] && readlink CLAUDE.md
grep -c "@" AGENTS.md CLAUDE.md 2>/dev/null  # imports

# ARCHITECTURE.md
find . -name "ARCHITECTURE.md" -o -name "ARCHITECTURE.rst" 2>/dev/null | grep -v node_modules | grep -v .git
wc -l ARCHITECTURE.md 2>/dev/null

# Domain context and ADRs
find . -maxdepth 4 \( -name "CONTEXT.md" -o -name "CONTEXT-MAP.md" -o -name "DOMAIN.md" \) 2>/dev/null | grep -v node_modules | grep -v .git
find . -type d -name "adr" -o -name "adrs" -o -name "decisions" -o -name "decision-records" 2>/dev/null | grep -v node_modules | grep -v .git
find . -path "*/adr/*.md" -o -path "*/adrs/*.md" -o -path "*/decisions/*.md" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l

# Topic documentation
find . -maxdepth 2 -name "CONVENTIONS.md" -o -name "TESTING.md" -o -name "DEPLOYMENT.md" -o -name "API.md" -o -name "DATABASE.md" -o -name "CONTRIBUTING.md" 2>/dev/null | grep -v node_modules | grep -v .git

# Also check docs/ directory for topic docs with different naming
find docs/ doc/ -maxdepth 1 -name "*.md" 2>/dev/null | grep -v node_modules | grep -v .git | head -20

# README
ls README.md README.rst README 2>/dev/null
wc -l README.md 2>/dev/null

# Docs directory
find docs/ -type f 2>/dev/null | head -20
find doc/ -type f 2>/dev/null | head -20

# Documentation CI enforcement
grep -r "markdown\|markdownlint\|link-check\|docs" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -5
```

### Coherence Evidence Commands

```bash
# Canonical agent-instruction content type analysis
DOC="AGENTS.md"
if [ ! -f "$DOC" ] && [ -f "CLAUDE.md" ]; then DOC="CLAUDE.md"; fi
echo "=== ${DOC} content breakdown ==="
if [ -f "$DOC" ]; then
  echo "Total lines: $(wc -l < "$DOC")"
  echo "Code block lines: $(sed -n '/^```/,/^```/p' "$DOC" | wc -l)"
  echo "Sections (## headings): $(grep -c '^##' "$DOC")"
  echo "Directive keywords (must/never/always/avoid/prefer): $(grep -ci 'must\|never\|always\|avoid\|prefer' "$DOC")"
  TOTAL=$(wc -l < "$DOC")
  CODE=$(sed -n '/^```/,/^```/p' "$DOC" | wc -l)
  if [ "$TOTAL" -gt 0 ]; then
    PCT=$(( CODE * 100 / TOTAL ))
    echo "Code example percentage: ${PCT}%"
  fi
fi

# Topic overlap: does the canonical instruction file cover topics that have dedicated docs?
echo "=== Topic overlap between ${DOC} and dedicated docs ==="
for doc in $(find docs/ doc/ -name "*.md" -maxdepth 2 2>/dev/null | grep -v node_modules); do
  TOPIC=$(basename "$doc" .md | tr '[:upper:]' '[:lower:]' | sed 's/_/ /g')
  if grep -qi "$TOPIC" "$DOC" 2>/dev/null; then
    ENTRY_LINES=$(grep -ci "$TOPIC" "$DOC" 2>/dev/null)
    DOC_LINES=$(wc -l < "$doc" 2>/dev/null | tr -d ' ')
    echo "  Overlap: '$TOPIC': ${DOC} mentions ${ENTRY_LINES}x, dedicated doc is ${DOC_LINES} lines"
  fi
done

# Validate @-imports and doc references resolve to real files
echo "=== Broken documentation references ==="
if [ -f "$DOC" ]; then
  # Check import-style references
  grep -oE '@[a-zA-Z0-9_./-]+\.md' "$DOC" 2>/dev/null | while read -r ref; do
    FILE=$(echo "$ref" | sed 's/^@//')
    if [ ! -f "$FILE" ]; then
      echo "  BROKEN import: $ref -> $FILE not found"
    fi
  done
  # Check markdown link references
  grep -oE '\[.*\]\(\./[^)]+\)' "$DOC" 2>/dev/null | grep -oE '\./[^)]+' | while read -r ref; do
    if [ ! -f "$ref" ]; then
      echo "  BROKEN link: $ref not found"
    fi
  done
fi

# Conflicting patterns: check if the canonical instruction file's "avoid" patterns appear as valid examples in topic docs
echo "=== Potential cross-document conflicts ==="
if [ -f "$DOC" ] && [ -d docs/ ]; then
  # Extract function/method patterns marked as "avoid" in the canonical instruction file
  grep -B1 -A3 '❌.*[Aa]void\|# ❌\|\/\/ ❌' "$DOC" 2>/dev/null | \
    grep -oE '[a-zA-Z]+\.[a-zA-Z]+\(|[a-zA-Z]+\(\)' | sort -u | while read -r pattern; do
    # Check if these "avoid" patterns appear as valid/recommended in topic docs
    TOPIC_HITS=$(grep -rl "$pattern" docs/ 2>/dev/null | grep -v node_modules)
    if [ -n "$TOPIC_HITS" ]; then
      # Verify the pattern isn't also marked as "avoid" in the topic doc
      for hit in $TOPIC_HITS; do
        if ! grep -B2 "$pattern" "$hit" 2>/dev/null | grep -qi 'avoid\|❌\|don.t'; then
          echo "  CONFLICT: ${DOC} marks '$pattern' as avoid, but $hit shows it as valid"
        fi
      done
    fi
  done
fi

# Source of truth declarations
echo "=== Source of truth declarations ==="
grep -rn "source of truth\|authoritative\|canonical\|definitive" AGENTS.md CLAUDE.md CONTEXT.md CONTEXT-MAP.md docs/ 2>/dev/null | grep -v node_modules | grep -v .git
```

## Scoring Bands

- **0-20**: No root agent instruction file, no ARCHITECTURE.md, no domain context, and no consequential ADRs. README is minimal or absent. Agent must infer everything from code alone.
- **21-40**: README exists with basic setup. No root agent instruction file or ARCHITECTURE.md. Agent has minimal guidance beyond code structure.
- **41-60**: A root instruction file exists but may be unstructured, bloated, or conflict with a duplicate. Some documentation is present, but domain terminology and durable decisions are undocumented or duplicated.
- **61-80**: The canonical instruction entrypoint is concise and delegates to topic docs. ARCHITECTURE.md has a codemap. Domain context and consequential ADRs are discoverable. Agents can navigate and understand most changes from documentation.
- **81-100**: A clear canonical instruction entrypoint and scoped docs have no duplication or conflicts. ARCHITECTURE.md is comprehensive, domain context has one glossary authority, ADRs are concise and maintained only for consequential trade-offs, and documentation verification runs in CI.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

## Score Modifiers

### Positive Modifiers
- **ADRs present and actively maintained** (written within last 6 months): **+5**
- **Scoped agent instruction files in 3+ directories, each justified by local rules**: **+5**
- **Documentation link checking in CI**: **+3**
- **All canonical-instruction imports and documentation references resolve to existing files**: **+3**

### Negative Modifiers
- **Canonical instruction file >500 lines without links or imports** (bloat anti-pattern): **-10**
- **Conflicting instructions detected** between the canonical instruction file and topic docs, or between AGENTS.md and CLAUDE.md: **-10**
- **Canonical instruction file duplicates content from topic docs** (>20 lines of overlapping content on the same topic without delegation): **-5**
- **Canonical instruction file code examples exceed 30% of total lines** (tutorial content that belongs in topic docs, not directive content): **-5**

## Output Format

```markdown
## Documentation Assessment

**Score: XX/100**

### Evidence
- Agent instructions: [canonical AGENTS.md / CLAUDE.md / absent: line count, links/imports, scoped files, alias status]
- Agent-instruction content profile: [code example %, directive keyword density, section count]
- ARCHITECTURE.md: [present / absent — line count, key sections found]
- Domain context: [CONTEXT.md / CONTEXT-MAP.md / DOMAIN.md; glossary authority and map coverage]
- ADRs: [count, most recent date, location, consequential vs boilerplate]
- Topic docs: [list of files found]
- README: [present / absent — line count, key sections found]
- Documentation CI: [link checking / freshness checks / none]

### Coherence
- Topic overlap: [list of topics covered in both the canonical instruction file and dedicated docs]
- Cross-document conflicts: [count and description of contradictions found]
- Source of truth clarity: [clear / ambiguous: details, including glossary authority]
- Broken references: [count of broken imports or markdown links]
- Agent-instruction role: [directive index / mixed / tutorial-heavy]

### Strengths
- [What's working well]

### Gaps
- [What's missing or weak]

### Recommendations
**Quick Wins (1-2 days):**
- [Specific actionable item]

**High-Value Investments (1-4 weeks):**
- [Specific actionable item]
```
