---
name: codebase-readiness
description: Run an Agent-Ready Codebase Assessment to score your codebase across 8 dimensions using parallel specialized agents. Produces a weighted score (0-100) with a band rating (Agent-Ready → Not Agent-Ready), improvement roadmap, and optional saved report. Framed around the Stripe benchmark of 1,000+ AI-generated PRs per week. Use when a developer or CTO wants to understand how ready their codebase is for autonomous AI agent work.
---

# Codebase Readiness Assessment

You are running an **Agent-Ready Codebase Assessment** — a scored evaluation of how well this codebase supports autonomous AI agent work, framed against the Stripe benchmark of 1,000+ AI-generated pull requests per week.

Work through the following phases sequentially.

---

## Phase 1: Codebase Reconnaissance

Run the following commands to build a **Codebase Snapshot** before launching assessment agents. Do this directly — no agent needed.

```bash
# Project name
basename $(pwd)

# Language/framework detection
ls package.json Gemfile pyproject.toml go.mod requirements.txt pom.xml 2>/dev/null
cat package.json 2>/dev/null | grep '"name"\|"main"\|"scripts"' | head -5
head -5 Gemfile 2>/dev/null
head -5 pyproject.toml 2>/dev/null
head -3 go.mod 2>/dev/null

# Size metrics
git rev-list --count HEAD 2>/dev/null || echo "Not a git repo or no commits"
git shortlog -sn HEAD 2>/dev/null | wc -l
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v spec | grep -v test | wc -l

# Test file ratio
find . -name "*_spec*" -o -name "*_test*" -o -name "*.spec.*" -o -name "*.test.*" -o -name "test_*.py" 2>/dev/null \
  | grep -v node_modules | grep -v .git | wc -l

# CI/CD presence
ls .github/workflows/ .circleci/ .buildkite/ .gitlab-ci.yml 2>/dev/null

# CLAUDE.md
find . -name "CLAUDE.md" 2>/dev/null | grep -v node_modules | grep -v .git
find . -name "CLAUDE.md" -exec wc -l {} \; 2>/dev/null | grep -v node_modules

# Linting/formatting configs
ls .eslintrc* .rubocop.yml .flake8 ruff.toml .golangci.yml .prettierrc* 2>/dev/null

# README
ls README.md README.rst README.txt 2>/dev/null
wc -l README.md 2>/dev/null
```

After running these commands, output a formatted **Codebase Snapshot**:

```
## Codebase Snapshot: [Project Name]

- **Primary language/framework**: [detected]
- **Language tier**: [statically-typed | dynamically-typed | gradually-typed]
  - Statically-typed: TypeScript, Go, Java, Rust, C#, Kotlin
  - Dynamically-typed: Ruby, Python (unannotated), JavaScript/Node.js
  - Gradually-typed: Python with mypy/Pydantic, TypeScript with strict:false
- **Commit count**: [X]
- **Contributors**: [X]
- **Source files**: [X]
- **Test files**: [X] (ratio: X%)
- **CI/CD**: [platform(s) found or none]
- **CLAUDE.md**: [present at path, X lines / absent]
- **Linting config**: [tools found or none]
- **README**: [present, X lines / absent]
```

Pass `LANGUAGE_TIER` and `PRIMARY_LANGUAGE` explicitly to each agent so they apply the correct language-specific rubrics.

---

## Phase 2: Launch 4 Assessment Agents in Parallel

Send a **single message** with **4 Task tool calls** to launch all agents simultaneously. Pass the full Codebase Snapshot as context in each prompt.

**Agent 1: test-coverage-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

Assess Test Foundation (0-100) and Feedback Loops (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

**Agent 2: documentation-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

Assess Documentation & Context (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

**Agent 3: code-clarity-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

Assess Code Clarity (0-100) and Consistency & Conventions (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

**Agent 4: architecture-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

Assess Type Safety (0-100), Architecture Clarity (0-100), and Change Safety (0-100) following your rubric. Apply the language-appropriate Type Safety rubric based on LANGUAGE_TIER. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

Wait for all 4 agents to complete before proceeding.

---

## Phase 3: Score Calculation

Weights are **language-adaptive**. Select the appropriate table based on `LANGUAGE_TIER` from the Codebase Snapshot.

### Dynamically-typed languages (Ruby, Python, JavaScript)

In dynamic languages, tests are the type system. Test Foundation carries more weight; Type Safety reflects contracts and interface clarity, not a type checker.

| Dimension                 | Agent                    | Weight | Agent Score | Weighted |
|---------------------------|--------------------------|--------|-------------|----------|
| Test Foundation           | test-coverage-assessor   | 25%    | XX/100      | XX       |
| Documentation & Context   | documentation-assessor   | 15%    | XX/100      | XX       |
| Code Clarity              | code-clarity-assessor    | 15%    | XX/100      | XX       |
| Architecture Clarity      | architecture-assessor    | 15%    | XX/100      | XX       |
| Feedback Loops            | test-coverage-assessor   | 10%    | XX/100      | XX       |
| Type Safety*              | architecture-assessor    | 10%    | XX/100      | XX       |
| Consistency & Conventions | code-clarity-assessor    | 5%     | XX/100      | XX       |
| Change Safety             | architecture-assessor    | 5%     | XX/100      | XX       |

*Type Safety for dynamic languages = contracts (dry-rb, Pydantic), ActiveRecord validations, Result pattern consistency. NOT penalized for absence of a type checker.

### Statically-typed languages (TypeScript, Go, Java, Rust)

| Dimension                 | Agent                    | Weight | Agent Score | Weighted |
|---------------------------|--------------------------|--------|-------------|----------|
| Type Safety               | architecture-assessor    | 20%    | XX/100      | XX       |
| Test Foundation           | test-coverage-assessor   | 15%    | XX/100      | XX       |
| Documentation & Context   | documentation-assessor   | 15%    | XX/100      | XX       |
| Code Clarity              | code-clarity-assessor    | 15%    | XX/100      | XX       |
| Architecture Clarity      | architecture-assessor    | 15%    | XX/100      | XX       |
| Feedback Loops            | test-coverage-assessor   | 10%    | XX/100      | XX       |
| Consistency & Conventions | code-clarity-assessor    | 5%     | XX/100      | XX       |
| Change Safety             | architecture-assessor    | 5%     | XX/100      | XX       |

**Overall Score** = sum of (agent score × weight)

**Score Bands:**
- **85-100**: Agent-Ready — codebase supports autonomous agent work
- **70-84**: Agent-Assisted — agents work well with human oversight
- **50-69**: Agent-Supervised — agents need heavy review before merging
- **30-49**: Agent-Caution — foundational improvements needed first
- **0-29**: Not Agent-Ready — significant investment required before agent work

---

## Phase 4: Report Assembly

Assemble and output the full report:

```markdown
# Agent-Ready Assessment: [Project Name]

## Overall Agent-Ready Score: XX/100
**Rating: [Band Name]**

[2-sentence interpretation — e.g., "This codebase can support AI agent work with human oversight on most changes. The test foundation and type system provide reasonable guard rails, but documentation gaps will cause agents to make incorrect assumptions about business intent."]

### Score Breakdown

| Dimension                 | Weight | Score   | Weighted |
|---------------------------|--------|---------|----------|
| Test Foundation           | 20%    | XX/100  | XX.X     |
| Documentation & Context   | 15%    | XX/100  | XX.X     |
| Code Clarity              | 15%    | XX/100  | XX.X     |
| Type Safety               | 15%    | XX/100  | XX.X     |
| Architecture Clarity      | 15%    | XX/100  | XX.X     |
| Consistency & Conventions | 10%    | XX/100  | XX.X     |
| Feedback Loops            | 5%     | XX/100  | XX.X     |
| Change Safety             | 5%     | XX/100  | XX.X     |
| **TOTAL**                 | 100%   |         | **XX/100** |

---

## Language Context: [Primary Language]

> **For dynamically-typed languages (Ruby, Python, JavaScript) only — omit for TypeScript/Go/Java.**

This codebase is written in **[Language]**, a dynamically-typed language. The scoring framework adapts for this:

| Signal | [Language] equivalent |
|--------|----------------------|
| Type Safety (10%) | Contract systems ([dry-rb/Pydantic/etc.]), validated interfaces, Result pattern |
| Test Foundation (25%) | [Language]'s primary safety mechanism — comprehensive tests catch what type checkers catch in TypeScript |

A **Type Safety score of 30-50 paired with a Test Foundation score of 75+** is a healthy Ruby/Python codebase — not a gap. The combined 35% weight (10% + 25%) provides the same safety signal as TypeScript's Type Safety at 20%.

---

## The Stripe Benchmark

Stripe's engineering team merged 1,000+ AI-generated pull requests in a single week. This is possible because Stripe's codebase satisfies what researchers call the **asymmetry of verification**: generating a PR is hard, but *verifying* one — with fast CI, strict types, and comprehensive tests — takes minutes. Every dimension in this assessment measures how well your codebase satisfies that asymmetry.

The goal is to make agent output cheaply verifiable: the cost of a wrong answer is low, the feedback loop is fast, and the automated verification layer catches mistakes before humans need to. A score of 70+ means that condition is largely met. Below 50 means the verification infrastructure needs to be built before agents can work reliably.

---

## Critical Findings
[List any dimensions scoring below 40, with the specific gap and why it blocks agent work]

---

## Verification Cost Profile

> How expensive is it to confirm an agent's change is correct in this codebase?

| Signal | Status | What it means |
|--------|--------|----------------|
| Tests run in < 10 min | ✓ / ✗ | Fast verification enables agent iteration cycles |
| Security scanning automated | ✓ / ✗ | Non-functional correctness covered without manual review |
| Property-based tests present | ✓ / ✗ | Oracle generates adversarial inputs, not just happy paths |
| Reproducible dev state (seeds/factories) | ✓ / ✗ | Agents can set up verifiable scenarios independently |
| Coverage reported on PRs | ✓ / ✗ | Regression signal visible before human review |

**Verification bottleneck:** [The single biggest barrier to confirming agent-produced changes — e.g., "No security scanning means agent-introduced vulnerabilities only surface in manual review or production" or "45-min CI limits agents to ~10 verification cycles per day"]

---

## Improvement Roadmap

### Quick Wins (1-2 days each)
[Consolidated list from all agent reports — highest-impact, lowest-effort items]

### High-Value Investments (1-4 weeks each)
[Consolidated list from all agent reports — significant improvements requiring dedicated effort]

### Long-Term Architecture (Ongoing)
[Strategic improvements that require sustained investment]

---

## Dimension Details

[Insert full agent reports for all 8 dimensions here, grouped by agent]

### Test Foundation & Feedback Loops
[test-coverage-assessor full report]

### Documentation & Context
[documentation-assessor full report]

### Code Clarity & Consistency
[code-clarity-assessor full report]

### Type Safety, Architecture & Change Safety
[architecture-assessor full report]

---

## What "Agent-Ready" Means

AI agent work doesn't eliminate verification — it relocates it. Before agents, developers split time between writing, reading, and checking code. With agents, writing is offloaded. But every line an agent produces still needs to be verified against human intent, either by automated systems or by humans reading code.

An agent-ready codebase maximizes automated verification and minimizes the cost per change:

- **Tests are the oracle** — when an agent makes a change, the test suite tells it immediately whether that change matches intent. Without tests, every agent change requires a human to read and reason about correctness manually — which destroys scalability. A noisy oracle (flaky tests, heavily mocked suites) is nearly as bad as no tests.
- **Type systems reduce verifier noise** — a type-checked build that passes is a higher-confidence signal than an untyped build that passes. Types convert silent runtime failures into loud compile-time failures, so agent mistakes are caught before a human ever reviews them.
- **Documentation makes intent verifiable** — CLAUDE.md and ADRs give agents the context to produce changes that match business intent, not just syntactic correctness. Without documented intent, an agent's change can pass every automated check and still be wrong in ways only a human reviewer can catch.
- **Small files bound the verification surface** — when a change is contained to one focused file, a test failure is attributable and precise. Large files and high coupling produce noisy feedback: a failure could be caused by any of a dozen interacting concerns.
- **Fast feedback enables iteration** — a 45-minute CI pipeline limits agents to ~10 verification cycles per day. A 5-minute pipeline enables ~100. Pipeline speed is a structural prerequisite for agent work at scale, not a convenience.
- **Security and vulnerability scanning extends coverage** — functional tests verify behavior; security scanners verify a different correctness dimension that agents can silently violate.

Each point in the Improvement Roadmap raises your verification limit — reducing manual review burden while increasing confidence in every agent-produced change.

---
*Generated by codebase-readiness skill — claude-code-workflows*
```

---

## Phase 5: Offer to Save Report

After presenting the report, ask:

> "Would you like me to save this assessment as `AGENT_READY_ASSESSMENT.md` in the project root? It can serve as a baseline for tracking improvements over time and is useful for sharing with your team."

If the user confirms, write the full report to `AGENT_READY_ASSESSMENT.md` in the current directory.

---

## Phase 6: CI Integration Recommendation

After saving (or if the user declines), mention:

> **For continuous tracking:** Consider adding [`btar`](https://github.com/btahq/btar) to your CI pipeline. It provides fast, deterministic measurement of your verification infrastructure (type errors, lint violations, test coverage) and can gate PRs when scores regress. This assessment gives you a strategic baseline; btar gives you daily CI enforcement of the most critical metrics.
>
> ```bash
> npm install -g btar
> btar analyze .          # Quick score: types + lint + coverage
> btar context generate agents-md  # Auto-generates AGENTS.md with your build/test commands
> ```
