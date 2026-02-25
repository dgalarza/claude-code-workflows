# Type Safety

## Why This Matters for Agent Readiness

Type safety determines what mechanisms prevent agent mistakes from silently passing through the system and reaching production. When an agent generates incorrect code, type enforcement acts as the first automated safety net — catching mismatched parameters, invalid data shapes, and contract violations before they reach runtime. The stronger the type safety infrastructure, the more confidently an agent can make changes knowing that errors will surface early.

## What to Examine

- **Language type tier**: Is the language statically-typed, dynamically-typed, or gradually-typed? This determines *how* safety is expressed, not *whether* it exists
- **Type enforcement mechanisms**: Whatever form safety takes in this language — are they present, configured, and enforced?
- **CI enforcement**: Do type checks run as a required gate in CI?
- **Semantic type names**: Does the codebase use domain-specific types (e.g., `UserId` vs bare `string`, `EmailAddress` vs `str`) that communicate intent and constrain valid values?
- **Database-level invariants**: Do database constraints (CHECK, NOT NULL, UNIQUE, REFERENCES, triggers, custom types/domains) extend type enforcement beyond application code?
- **API contract types**: Are API boundaries typed via OpenAPI specs or generated clients, ensuring external integrations are type-safe?
- **Strictness level**: Is the type system configured at its strictest practical level, or are escape hatches (any types, type:ignore, unsafe casts) widespread?

## Evidence-Gathering Commands

```bash
# Database constraints (works for any language with migrations)
grep -r "check\|constraint\|NOT NULL\|UNIQUE\|REFERENCES\|trigger" db/migrate/ migrations/ 2>/dev/null | grep -v node_modules | grep -v .git | wc -l
grep -r "CREATE TRIGGER\|CREATE TYPE\|CREATE DOMAIN" db/ 2>/dev/null | head -5

# OpenAPI / generated typed clients
find . -name "openapi*" -o -name "swagger*" 2>/dev/null | grep -v node_modules | grep -v .git | head -5
```

NOTE: Type checker detection, configuration analysis, and escape-hatch counting commands are language-specific and live in language files.

## Scoring Bands

- **0-20**: No type safety mechanisms in place. No type checker, no contract enforcement, no runtime validation. Agent mistakes pass silently.
- **21-40**: Minimal type safety. Some mechanisms exist but are not enforced in CI, have low coverage, or are configured at a permissive level. Escape hatches are common.
- **41-60**: Moderate type safety. Type enforcement is configured and partially enforced. CI may run checks but they are not strict or not required. Some domain types exist but usage is inconsistent.
- **61-80**: Strong type safety. Type enforcement is active and CI-enforced. Strict configuration with few escape hatches. Semantic domain types are used in key areas. Most code paths are covered.
- **81-100**: Comprehensive type safety. Strictest configuration enforced in CI with near-zero escape hatches. Semantic types used pervasively. Domain boundaries are type-enforced.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

## Score Modifiers

- **Database-level invariants present** (CHECK constraints, triggers, custom types/domains actively used): **+5**
- **OpenAPI with generated typed clients**: **+5**

## Output Format

```markdown
## Type Safety Assessment

**Score: XX/100**

### Evidence
- Language: [detected]
- Language tier: [statically-typed / dynamically-typed / gradually-typed]
- [Language-specific evidence items — agent will fill based on language file]
- CI enforcement: [yes/no — details]

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
