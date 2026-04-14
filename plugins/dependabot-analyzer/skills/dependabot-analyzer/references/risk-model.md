# Risk Scoring Model

Score each Dependabot PR from 0–100 using the factors below. Add the points from each factor to produce a total risk score.

## Factors

### 1. Semver Bump (0–30)

| Bump Type | Points |
|-----------|--------|
| Patch     | 0      |
| Minor     | 10     |
| Major     | 30     |

### 2. CI Status (0–25)

| Status  | Points |
|---------|--------|
| Passing | 0      |
| Pending | 10     |
| Failing | 25     |

### 3. Breaking Changes (0–20)

Assess from the changelog, release notes, and diff.

| Finding                                  | Points |
|------------------------------------------|--------|
| No breaking changes                      | 0      |
| Breaking changes with documented migration | 10   |
| Breaking changes without migration guide | 20     |

### 4. Dependency Health (0–10)

Use output from `check-dep-health.sh`.

| Rating    | Points |
|-----------|--------|
| Good      | 0      |
| Fair      | 5      |
| Stale     | 7      |
| Abandoned or has known vulnerabilities | 10 |

### 5. Dependency Location (0–5)

| Location          | Points |
|-------------------|--------|
| Dev dependency    | 0      |
| Production dependency | 5  |

### 6. Diff Size (0–5)

| Lines Changed | Points |
|---------------|--------|
| < 50          | 0      |
| 50–199        | 2      |
| 200–499       | 3      |
| 500+          | 5      |

### 7. Transitive Impact (0–5)

Estimate from lockfile changes — how many transitive dependencies are affected.

| Transitive Deps Changed | Points |
|--------------------------|--------|
| 0–2                      | 0      |
| 3–5                      | 2      |
| 6+                       | 5      |

## Override Rules

Apply these after computing the base score:

- **Security fix**: If the update addresses a known vulnerability in the current version, cap the score at 20 regardless of other factors. Add a note: "Security fix — fast-track recommended."
- **Major framework upgrade**: If the dependency is a core framework (e.g., React, Rails, Django, Next.js, Express), add 10 points to the base score. These have outsized blast radius.
- **Stale PR**: If the PR has been open for more than 30 days, add a staleness note (but do not change the score). Stale PRs may have merge conflicts or outdated lockfiles.

After applying all overrides, **clamp the final score to 0–100**.

## Risk Bands

| Score | Band     | Recommended Action |
|-------|----------|--------------------|
| 0–20  | Safe     | Auto-merge (if config allows) |
| 21–40 | Low      | Auto-merge with note |
| 41–60 | Medium   | Create issue for review |
| 61–80 | High     | Create issue, flag for prompt attention |
| 81–100| Critical | Create issue, block merge, escalate |
