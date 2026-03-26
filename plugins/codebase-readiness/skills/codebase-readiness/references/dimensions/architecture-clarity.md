# Architecture Clarity

## Why This Matters for Agent Readiness

Architecture clarity determines whether an agent can understand where to make a change without reading the entire codebase. When domain boundaries are visible in the filesystem, an agent can reason about one vertical slice at a time, apply domain-specific instructions, and scope its changes confidently. Without this clarity, every change requires global understanding — which exceeds practical context limits and increases the risk of unintended cross-domain side effects.

## What to Examine

- **Domain boundary visibility**: The PRIMARY signal. Are business domains expressed as distinct filesystem subtrees, not just conceptual groupings?
  - When boundaries are NOT in the filesystem, agents cannot: reason about one vertical in isolation, benefit from domain-specific CLAUDE.md files, apply scoped skills, or limit blast radius
  - Good visibility means: each domain lives in its own subtree, cross-domain dependencies are explicit, and each domain has a natural home for domain-specific documentation
- **Domain grouping consistency**: Within domain directories, do files follow consistent naming and organization? Or are some files at the root level while others are properly nested?
- **Service/domain layer presence**: Is business logic separated from transport/presentation concerns (thin controllers, service objects, use cases, interactors)?
- **God objects / large shared files**: Are there oversized files that concentrate cross-cutting logic, making it impossible to reason about one domain in isolation?
- **Nested CLAUDE.md files**: The presence of domain-scoped CLAUDE.md files signals intentional boundary design for agent consumption
- **Dependency explicitness**: Can you trace which domains depend on which by examining imports/requires, or are dependencies implicit and global?

## Evidence-Gathering Commands

```bash
# Top-level directory structure
ls -la
find . -maxdepth 3 -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v vendor | grep -v ".bundle" | sort | head -50

# Domain/vertical directories
find . -maxdepth 4 -type d \( -name "domain" -o -name "domains" -o -name "bounded_contexts" -o -name "contexts" \) 2>/dev/null | grep -v node_modules | grep -v .git

# Service layer
find . -type d \( -name "services" -o -name "domain" -o -name "use_cases" -o -name "interactors" \) 2>/dev/null | grep -v node_modules | grep -v .git

# God objects / large shared files
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" -o -name "*.php" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test \
  | xargs wc -l 2>/dev/null | sort -rn | head -15

# Nested CLAUDE.md files (signals intentional domain scoping)
find . -name "CLAUDE.md" 2>/dev/null | grep -v node_modules | grep -v .git

# Dependency management files
ls package.json Gemfile requirements*.txt pyproject.toml go.mod composer.json 2>/dev/null
```

### Domain Grouping Consistency Check

For each domain directory that groups source files, check whether files are properly nested or leaking to the root level:

```bash
# Pick a representative domain source directory (e.g., app/services, src/domain)
SOURCE_DIR="app/services"  # adjust per codebase

if [ -d "$SOURCE_DIR" ]; then
  TOTAL=$(find "$SOURCE_DIR" -type f 2>/dev/null | wc -l)
  ROOT_FILES=$(find "$SOURCE_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)
  SUBDIR_FILES=$(find "$SOURCE_DIR" -mindepth 2 -type f 2>/dev/null | wc -l)
  echo "Total files: $TOTAL"
  echo "Root-level files (not in subdirectory): $ROOT_FILES"
  echo "Files in subdirectories: $SUBDIR_FILES"
  if [ "$TOTAL" -gt 0 ]; then
    PCT=$(( ROOT_FILES * 100 / TOTAL ))
    echo "Root-level leakage: ${PCT}%"
  fi
fi
```

## Scoring Bands

- **0-20**: Business logic lives in controllers/views/handlers with no separation. No service or domain layer. Verticals are fully intermingled — changing one feature requires touching files across many directories with no clear grouping.
- **21-40**: Some separation exists but is inconsistent. Multiple domains share the same models/services directories. Business logic partially extracted but no clear domain boundaries in the filesystem.
- **41-60**: Service layer present, conventions partially followed. Domain subdirectories exist BUT are unreliable — more than 25% root-level leakage, inconsistent naming across layers. Agent can sometimes reason about one domain but must verify assumptions.
- **61-80**: Clear service/domain layer with thin controllers. Domain subdirectories reliably used (less than 25% root leakage). Names align across layers. Agent can usually navigate to the right domain confidently.
- **81-100**: Each domain is independently navigable in the file tree. Domains live in their own subtrees with explicit cross-domain dependencies. Each domain has a natural home for domain-specific CLAUDE.md. Agent can reason about a single domain without understanding the whole codebase.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

## Score Modifiers

- **Nested CLAUDE.md files** present in domain directories: **+5**
- **God files** (files >1000 lines of business logic) in shared directories: **-5 per god file** (up to -15)

## Output Format

```markdown
## Architecture Clarity Assessment

**Score: XX/100**

### Evidence
- Directory structure: [flat / layered / domain-organized]
- Domain boundaries in filesystem: [yes / partial / no]
- Domain grouping consistency: [XX% root-level leakage]
- Service/domain layer: [present / partial / absent]
- God objects found: [count, with largest listed]
- Nested CLAUDE.md files: [count, locations]
- Cross-domain dependency explicitness: [explicit / implicit / mixed]

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
