# Change Safety

## Why This Matters for Agent Readiness

Change safety determines how contained the blast radius is when an agent makes a modification. Agents work best when changes are isolated — a fix in one module should not unexpectedly break behavior in another. Codebases with high coupling, no feature flags, and unsafe migration patterns force agents into a mode where every change carries disproportionate risk, reducing the scope of work they can safely perform autonomously.

## What to Examine

- **Coupling indicators via co-change analysis**: Which files frequently change together? High co-change frequency between unrelated modules signals hidden coupling that will trip up agents
- **File churn**: Files that change most frequently represent both coupling risk and high-value targets for structural improvement
- **Feature flag infrastructure**: Can new behavior be deployed behind flags, enabling safe incremental rollout? This is critical for agent-authored changes that may need quick rollback
- **Database migration safety**: Are migrations reversible? Do they avoid destructive operations (dropping columns/tables) without safeguards? Are there patterns for safe schema changes (add-then-migrate-then-remove)?
- **Module/service boundary clarity**: Are boundaries between components enforced (via interfaces, dependency injection, explicit APIs) or merely conventional?
- **Rollback capability**: How quickly can a change be reverted if it causes problems?

## Evidence-Gathering Commands

```bash
# Co-change analysis — files that frequently appear in the same commit
git log --name-only --pretty=format: 2>/dev/null | grep -v "^$" | sort | uniq -c | sort -rn | head -20

# Most frequently changed files (churn = coupling risk)
git log --name-only --format="" 2>/dev/null | grep -v "^$" | sort | uniq -c | sort -rn | head -15

# Feature flags (generic patterns across languages)
grep -r "feature_flag\|feature_enabled\|featureFlag\|feature_toggle\|FeatureFlag\|FEATURE_" \
  --include="*.rb" --include="*.ts" --include="*.tsx" --include="*.py" --include="*.go" --include="*.java" --include="*.js" --include="*.php" \
  . 2>/dev/null | grep -v node_modules | grep -v .git | grep -v spec | grep -v test | wc -l

# Database migrations
find . -name "*.rb" -path "*/migrations/*" -o -name "*.py" -path "*/migrations/*" -o -name "*.php" -path "*/migrations/*" -o -name "*.sql" 2>/dev/null | grep -v .git | grep -v vendor | wc -l

# Migration safety patterns — look for irreversible operations
grep -r "drop_table\|drop_column\|remove_column\|dropTable\|dropColumn\|DROP TABLE\|DROP COLUMN\|rename_table\|rename_column\|renameColumn" \
  db/migrate/ migrations/ database/migrations/ 2>/dev/null | grep -v .git | grep -v vendor | head -10

# Rollback patterns
grep -r "reversible\|def down\|def change\|function down\|rollback\|downgrade" db/migrate/ migrations/ database/migrations/ 2>/dev/null | grep -v .git | grep -v vendor | wc -l
```

## Scoring Bands

- **0-20**: High coupling evident (many files co-change across unrelated modules). No feature flags. Migrations are irreversible or unsafe. No clear module boundaries — changes routinely cascade.
- **21-40**: Some module separation but co-change analysis reveals hidden coupling. Feature flags absent or ad-hoc. Migrations exist but safety patterns inconsistent. Rollback is manual and risky.
- **41-60**: Moderate separation. Co-change mostly within related modules. Feature flag infrastructure exists but used inconsistently. Most migrations are reversible. Some boundary enforcement.
- **61-80**: Good separation. Co-change largely confined to single modules. Feature flags used for significant changes. Safe migration patterns followed consistently. Clear module boundaries with some enforcement.
- **81-100**: Excellent isolation. Co-change analysis confirms independent modules. Feature flag infrastructure mature and consistently used. All migrations follow safe patterns (add-migrate-remove). Module boundaries enforced via interfaces or explicit APIs. Rapid rollback capability.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

## Score Modifiers

- **Feature flag infrastructure mature and actively used**: **+5**
- **Safe migration patterns documented and enforced**: **+3**
- **Circular dependencies detected between modules**: **-10**
- **Top 5 most-changed files are all in shared/common directories**: **-5**

## Output Format

```markdown
## Change Safety Assessment

**Score: XX/100**

### Evidence
- Co-change coupling: [low / moderate / high — with top clusters listed]
- Highest-churn files: [top 5 with change counts]
- Feature flags: [mature / basic / absent — count of usages]
- Migration safety: [safe patterns / mixed / unsafe]
- Module boundaries: [enforced / conventional / absent]
- Rollback capability: [rapid / manual / unknown]

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
