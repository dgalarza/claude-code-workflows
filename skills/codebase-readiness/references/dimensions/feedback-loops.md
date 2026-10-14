# Feedback Loops

## Why This Matters for Agent Readiness

Feedback loops determine how quickly an agent can iterate. A 5-minute CI pipeline enables roughly 100 iterations per day; a 45-minute pipeline allows roughly 10. Speed is a structural prerequisite — the faster the feedback, the more the agent can attempt, verify, and correct within a given time window. Beyond speed, the breadth of signals (security scanning, dependency auditing, coverage reporting) determines whether the agent gets comprehensive feedback or only partial verification.

## What to Examine

- **CI/CD presence and platform**: Is there a CI/CD system? Which platform (GitHub Actions, CircleCI, BuildKite, GitLab CI, Jenkins, etc.)?
- **Pipeline speed**: Estimated wall-clock time from push to green/red signal. This is the fundamental constraint on agent iteration rate
- **Caching**: Are dependencies and build artifacts cached between runs to avoid redundant work?
- **Test parallelization**: Are tests split across parallel jobs or shards to reduce wall-clock time?
- **Fail-fast configuration**: Does the pipeline abort early on first failure rather than running all jobs to completion?
- **Pre-commit hooks**: Are there local checks (lint, format, type check) that catch issues before they reach CI?
- **Non-functional verification signals**: Beyond tests, does CI provide:
  - Security scanning (SAST, dependency vulnerability scanning)
  - Coverage reporting (absolute thresholds and delta on PRs)
  - Dependency auditing (Dependabot, Renovate, scheduled audits)
- **Ephemeral and concurrent dev environments**: Can agents spin up isolated environments that do not interfere with each other or with human developers? Four signals to check:
  - Containerized/reproducible dev setup (Docker, devcontainer, Nix)
  - Per-branch or per-PR environments
  - Independent database/state per environment
  - No shared mutable state between environments
- **Quality-gate actionability and reproducibility (ergonomics slice)**: When the structural quality gate (complexity, duplication, dead code) reports findings on a PR, are they actionable -- inline annotations or a summary scoped to files changed since the merge-base? Is the local command identical to the CI command (`report` / `check` / `baseline`, documented in AGENTS.md or a guide)? Does the gate have its own tests? See `references/quality-gates.md` -- this dimension credits **actionability, reproducibility, and gate tests**, not which tools are used (Code Clarity) or whether the gate blocks (Change Safety)

## Evidence-Gathering Commands

```bash
# CI config presence
find .github/workflows .circleci .buildkite .gitlab -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -10
wc -l .github/workflows/*.yml 2>/dev/null | sort -rn | head -5

# Caching in CI
grep -r "cache\|Cache" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -10

# Parallel execution
grep -r "parallel\|matrix\|shard\|split" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -10

# Fail-fast configuration
grep -r "fail-fast\|failFast\|fail_fast" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -5

# Pre-commit hooks
ls .husky/ 2>/dev/null && ls .husky/
ls .pre-commit-config.yaml 2>/dev/null
ls lefthook.yml 2>/dev/null

# Coverage in CI feedback
grep -r "codecov\|coveralls\|coverage-report\|lcov\|coverage" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -5

# Dependency vulnerability scanning
ls .github/dependabot.yml 2>/dev/null && echo "Dependabot configured"
ls renovate.json .renovaterc 2>/dev/null && echo "Renovate configured"

# Security scanning in CI
grep -r "security\|sast\|codeql\|snyk\|trivy\|semgrep\|brakeman\|bandit\|gosec" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -5

# Ephemeral environment signals
ls docker-compose*.yml Dockerfile .devcontainer/ 2>/dev/null
grep -r "review-app\|preview\|ephemeral\|per-branch" .github/ .circleci/ .buildkite/ 2>/dev/null | grep -v ".git" | head -5

# Quality-gate actionability and reproducibility (see references/quality-gates.md)
grep -rnE "merge-base|fetch-depth: 0|changed-files|--changed-only|new-from|reviewdog|danger|::error|problem-matcher|annotations" .github/workflows .gitlab-ci.yml .circleci .buildkite 2>/dev/null | head -10
grep -nE "quality|gate|baseline|complexity|duplication" Makefile Rakefile justfile package.json composer.json 2>/dev/null | head -10
ls scripts/quality* script/quality* bin/quality* tools/quality* 2>/dev/null
grep -rnE "quality-gate|quality gate|baseline" AGENTS.md CLAUDE.md docs/guides/*.md 2>/dev/null | head -5
find . -path ./node_modules -prune -o -path ./vendor -prune -o \( -iname "*quality*gate*test*" -o -iname "test_quality_gate*" -o -iname "quality-gate*.spec.*" \) -print 2>/dev/null
```

## Scoring Bands

- **0-20**: No CI/CD pipeline. Agent changes cannot be verified automatically. No feedback mechanism beyond manual testing.
- **21-40**: Basic CI exists and runs tests, but no caching or parallelization. Estimated pipeline time exceeds 15 minutes. No pre-commit hooks. Feedback is slow and limited to pass/fail.
- **41-60**: CI with caching configured. Estimated pipeline under 15 minutes. Some additional signals beyond tests (coverage or linting). Agent gets reasonably fast feedback but misses optimization opportunities.
- **61-80**: Caching, parallel job execution, and pre-commit hooks all present. Estimated pipeline under 10 minutes. Multiple verification signals (tests, coverage, linting). Agent iterates efficiently with good feedback breadth.
- **81-100**: Estimated sub-5-minute CI. Parallel execution, pre-commit hooks, fail-fast configuration, security scanning, coverage reporting on PRs. Agent gets fast, comprehensive feedback on every change.

NOTE: For dimensions where scoring bands differ materially by language, these bands provide the general framing. The language file provides concrete criteria and tooling-specific thresholds.

**Gate ergonomics:** the 81-100 band includes a structural quality gate whose PR feedback is actionable (inline or changed-files-scoped) and whose local command matches CI. Apply the modifiers below only for the gate's ergonomics; blocking behaviour is scored under Change Safety.

## Score Modifiers

- **Ephemeral + concurrent dev environments** (all 4 signals present): **+8**; partial (1-2 signals): **+3**
- **Security scanner in CI**: **+5**
- **Dependabot, Renovate, or scheduled dependency audit**: **+3**
- **Coverage delta reported on PRs**: **+2**
- **Quality-gate findings annotated inline on PRs or scoped to changed files (merge-base aware)**: **+4**
- **Same quality-gate command runs locally and in CI, documented for agents**: **+3**
- **The quality gate has its own tests** (legacy passes / new fails / stale pruned): **+3**

## Output Format

```markdown
## Feedback Loops Assessment

**Score: XX/100**

### Evidence
- CI platform: [platform name]
- Estimated pipeline time: [X minutes — basis for estimate]
- Caching: [yes / no — what is cached]
- Parallelization: [yes / no — details]
- Fail-fast: [yes / no]
- Pre-commit hooks: [present / absent — tool and checks]
- Coverage reporting: [in CI / on PRs / absent]
- Security scanning: [present / absent — tools]
- Dependency scanning: [present / absent — tool]
- Ephemeral environments: [full / partial / absent — signals found]
- Quality-gate actionability: [inline annotations / changed-files summary / full-repo dump / no gate]
- Quality-gate reproducibility: [same command local and CI, documented at ... / CI-only / none]
- Quality-gate tests: [present at ... / absent]

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
