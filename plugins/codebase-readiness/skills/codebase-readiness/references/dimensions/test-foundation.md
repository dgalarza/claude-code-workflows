# Test Foundation

## Why This Matters for Agent Readiness

Tests are the primary verification mechanism an agent uses to confirm its changes are correct. Without a reliable test foundation, an agent operates blind — it can generate code but cannot verify it works. The quality of the test foundation directly determines the scope of changes an agent can safely make autonomously. A codebase with 100% meaningful coverage represents a phase change: the agent can modify any file and get immediate, reliable feedback on correctness.

## What to Examine

- **Test-to-source file ratio**: The primary structural metric. What percentage of source files have corresponding test files?
- **Coverage configuration**: Is a coverage tool configured? What thresholds are set?
- **CI enforcement**: Does CI fail when coverage drops below thresholds?
- **Test pyramid indicators**: Is there a healthy distribution across unit tests, integration tests, and end-to-end tests? Or is coverage concentrated in one layer?
- **Oracle quality**: How reliable is the verification signal the tests provide?
  - **Flaky test evidence**: Git history with "flaky", "intermittent", "skip test" commits signals unreliable oracles
  - **Mock/stub density**: When mocks greatly outnumber real interactions, tests may pass while real behavior fails
  - **Property-based testing**: Tests with adversarial/randomized inputs catch edge cases agents might introduce
  - **Integration test presence**: Unit tests alone miss interaction bugs — integration tests verify components work together
- **Mutation testing presence**: Does the codebase use mutation testing to verify test quality, not just coverage quantity?

## Evidence-Gathering Commands

```bash
# Test file counts (underscore convention — e.g., user_test.go, user_spec.rb)
find . -name "*_test*" -o -name "*_spec*" -o -name "test_*" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | grep -v vendor | wc -l

# Test file counts (dot convention — e.g., user.test.ts, user.spec.js)
find . -name "*.test.*" -o -name "*.spec.*" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | wc -l

# Source file count (for ratio calculation — adjust extensions per language)
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | grep -v vendor | grep -v spec | grep -v test | grep -v __tests__ | wc -l

# Test organization — how tests are structured
find . -type d \( -name "spec" -o -name "test" -o -name "tests" -o -name "__tests__" -o -name "e2e" -o -name "integration" -o -name "unit" \) 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | head -10

# Flaky test indicators in git history
git log --oneline 2>/dev/null | grep -i "flak\|intermit\|flakey\|skip test\|disable test" | wc -l

# Coverage configuration presence
find . -name ".coveragerc" -o -name "coverage.config*" -o -name ".nycrc*" -o -name "jest.config*" -o -name "codecov.yml" -o -name ".simplecov" 2>/dev/null \
  | grep -v node_modules | grep -v .git | head -5

# CI coverage enforcement
grep -r "coverage\|--cov\|simplecov\|codecov\|coveralls" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v .git | head -10
```

## Scoring Bands

- **0-20**: No tests or less than 5% test-to-source ratio. Agent has no verification mechanism for its changes.
- **21-40**: Tests exist but less than 20% ratio. No coverage configuration. No CI enforcement. Tests provide spotty verification at best.
- **41-60**: 20-40% test-to-source ratio. Coverage configuration present. Some CI integration. Agent can verify changes in well-tested areas but must be cautious elsewhere.
- **61-80**: 40-60% ratio. Coverage thresholds enforced in CI. Test pyramid visible (unit + integration layers). Agent can verify most changes with reasonable confidence.
- **81-100**: Greater than 60% ratio. Coverage enforced in CI with meaningful thresholds. Test pyramid healthy. Mutation testing or property-based tests present. Agent can verify changes comprehensively.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

## Score Modifiers

- **Property-based testing present and actively used**: **+5**
- **Test retry/flaky-test plugins present** (signals systemic flakiness): **-10**
- **Skipped/disabled tests exceed 5% of total**: **-5**
- **Mock/stub count exceeds 3x test file count**: **-5**
- **All tests are unit tests with no integration layer**: **-10**

## Output Format

```markdown
## Test Foundation Assessment

**Score: XX/100**

### Evidence
- Test-to-source file ratio: [X test files / Y source files = Z%]
- Coverage configuration: [present / absent — tool and thresholds if present]
- CI coverage enforcement: [yes / no — details]
- Test pyramid: [unit only / unit + integration / unit + integration + e2e]
- Flaky test signals: [count of git commits mentioning flakiness]
- Mock/stub density: [low / moderate / high]
- Property-based testing: [present / absent]
- Mutation testing: [present / absent]

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
