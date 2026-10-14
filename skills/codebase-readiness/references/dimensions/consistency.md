# Consistency & Conventions

## Why This Matters for Agent Readiness

Consistency determines whether an agent can learn patterns from one part of the codebase and apply them reliably elsewhere. When code style, formatting, and architectural patterns are enforced automatically, the agent generates code that fits seamlessly. Without enforcement, the agent must guess which style to follow — and inconsistent style across the codebase means any guess may be wrong. Automated enforcement also acts as a safety net: if the agent produces code that violates conventions, linters and formatters catch it before it reaches review.

## What to Examine

- **Linting configuration**: Is a linter configured? How strict is it? Are rules customized for the project or just defaults?
- **Formatter configuration**: Is an auto-formatter configured? Is it opinionated (single way to format) or flexible?
- **Pre-commit hooks enforcing lint/format**: Do local hooks catch violations before code is committed?
- **CI pipeline enforcement**: Does CI fail when lint or format violations are present? Is this a required check?
- **Custom/architectural linters**: Beyond style rules, are there linters that enforce architectural decisions and domain rules? These are especially valuable for agents because:
  - They encode decisions that are hard to infer from code alone
  - Error messages act as "context injection" — when an agent violates a rule, the error message teaches it the correct approach
  - Examples: "don't import from domain X in domain Y", "all API handlers must call authorize()", "database queries must go through the repository layer"
- **Lint legacy-debt treatment (style slice)**: How is pre-existing lint debt handled? A todo or baseline file (`.rubocop_todo.yml`, `phpstan-baseline`, ESLint baseline) that shrinks over time and is pruned when violations are fixed is a ratchet; one that only grows, or hundreds of inline disables, is suppression. See `references/quality-gates.md` -- this dimension credits **style tooling and lint-debt treatment** only; complexity, duplication, and dead-code checks are scored under Code Clarity

## Evidence-Gathering Commands

```bash
# Pre-commit hooks
ls .husky/ 2>/dev/null && echo "=== Husky hooks ===" && ls .husky/
ls .pre-commit-config.yaml 2>/dev/null && echo "=== pre-commit config ===" && head -30 .pre-commit-config.yaml
ls lefthook.yml 2>/dev/null && echo "=== Lefthook config ===" && head -30 lefthook.yml

# CI enforcement of lint/format
grep -r "lint\|format\|style\|rubocop\|eslint\|prettier\|black\|ruff\|golangci\|checkstyle\|spotless" \
  .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -10

# Lint/format config files (generic — covers most ecosystems)
find . -maxdepth 2 \( \
  -name ".eslintrc*" -o -name ".prettierrc*" -o -name ".rubocop.yml" -o \
  -name "pyproject.toml" -o -name ".flake8" -o -name ".pylintrc" -o \
  -name ".golangci.yml" -o -name "checkstyle.xml" -o -name ".scalafmt.conf" -o \
  -name "biome.json" -o -name "deno.json" -o -name ".stylelintrc*" \
\) 2>/dev/null | grep -v node_modules | grep -v .git

# Lint legacy-debt treatment (see references/quality-gates.md)
for f in .rubocop_todo.yml phpstan-baseline.neon eslint-baseline.json .eslint-baseline.json; do
  [ -f "$f" ] && echo "$f: $(wc -l < "$f") lines; commits touching it: $(git log --format=%h -- "$f" 2>/dev/null | wc -l); last change: $(git log --format=%cs -1 -- "$f" 2>/dev/null)"
done
# Inline suppressions substituting for a baseline
grep -rEc "eslint-disable|rubocop:disable|noqa|nolint|@SuppressWarnings|phpcs:ignore|# type: ignore" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.rb" --include="*.py" --include="*.go" --include="*.java" --include="*.php" . 2>/dev/null \
  | grep -v ":0$" | grep -v node_modules | grep -v vendor | awk -F: '{s+=$2} END {print "inline suppressions:", s+0}'
```

NOTE: Detailed linter/formatter detection, rule counting, and strictness analysis commands are language-specific and belong in language files.

## Scoring Bands

- **0-20**: No linting configuration. No formatter. Code style varies across files with no consistency. Agent has no automated feedback on style violations.
- **21-40**: Linting configuration exists but is not enforced in CI. No pre-commit hooks. Formatter may be configured but not required. Agent may generate code that passes locally but violates unstated conventions.
- **41-60**: Linting enforced in CI, OR formatter configured and used — but not both enforced together. Some style consistency achieved but gaps remain. Agent gets partial automated feedback.
- **61-80**: Both linting and formatting configured. CI enforces at least one. Pre-commit hooks present. Style is largely consistent across the codebase. Agent gets reliable feedback on most style issues.
- **81-100**: Linting and formatting both enforced in CI (build fails on violations). Auto-format runs on commit via hooks. Custom/architectural linters enforce domain rules beyond style. Agent gets comprehensive, immediate feedback on both style and architectural violations.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

**Lint-debt treatment:** the 81-100 band assumes lint violations fail CI *and* legacy debt is either cleared or held in a baseline that is pruned as it shrinks. A baseline that only grows is a suppression mechanism and does not qualify for the top band.

## Score Modifiers

- **Custom/architectural linters present** (enforcing domain rules, not just style): **+10**
- **Auto-format on commit** (via pre-commit hooks): **+3**
- **Linter configured but >20% of rules disabled/overridden**: **-5**
- **Lint baseline / todo file that shrinks over time** (git history shows removals): **+5**
- **Lint baseline that has only grown, or more than 100 inline suppressions without a baseline**: **-5**

## Output Format

```markdown
## Consistency & Conventions Assessment

**Score: XX/100**

### Evidence
- Linter: [tool name — configured / CI-enforced / absent]
- Formatter: [tool name — configured / CI-enforced / absent]
- Pre-commit hooks: [present / absent — what they enforce]
- CI enforcement: [lint only / format only / both / neither]
- Custom/architectural linters: [present / absent — description if present]
- Lint legacy-debt treatment: [cleared / pruned baseline / growing baseline / inline suppressions -- counts and last-shrink date]

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
