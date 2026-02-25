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
- **Commit count**: [X]
- **Contributors**: [X]
- **Source files**: [X]
- **Test files**: [X] (ratio: X%)
- **CI/CD**: [platform(s) found or none]
- **CLAUDE.md**: [present at path, X lines / absent]
- **Linting config**: [tools found or none]
- **README**: [present, X lines / absent]
```

---

## Phase 2: Launch 4 Assessment Agents in Parallel

Send a **single message** with **4 Task tool calls** to launch all agents simultaneously. Pass the full Codebase Snapshot as context in each prompt.

**Agent 1: test-coverage-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

Assess Test Foundation (0-100) and Feedback Loops (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

**Agent 2: documentation-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

Assess Documentation & Context (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

**Agent 3: code-clarity-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

Assess Code Clarity (0-100) and Consistency & Conventions (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

**Agent 4: architecture-assessor**
Prompt template:
```
You are assessing codebase readiness. Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

Assess Type Safety (0-100), Architecture Clarity (0-100), and Change Safety (0-100) following your rubric. Run the shell commands in your instructions to gather evidence. Return the full scored assessment in the required output format.
```

Wait for all 4 agents to complete before proceeding.

---

## Phase 3: Score Calculation

Collect the dimension scores from the agent reports and apply the weighted formula:

| Dimension                 | Agent                    | Weight | Agent Score | Weighted |
|---------------------------|--------------------------|--------|-------------|----------|
| Test Foundation           | test-coverage-assessor   | 20%    | XX/100      | XX       |
| Documentation & Context   | documentation-assessor   | 15%    | XX/100      | XX       |
| Code Clarity              | code-clarity-assessor    | 15%    | XX/100      | XX       |
| Type Safety               | architecture-assessor    | 15%    | XX/100      | XX       |
| Architecture Clarity      | architecture-assessor    | 15%    | XX/100      | XX       |
| Consistency & Conventions | code-clarity-assessor    | 10%    | XX/100      | XX       |
| Feedback Loops            | test-coverage-assessor   | 5%     | XX/100      | XX       |
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

## The Stripe Benchmark

Stripe's engineering team merged 1,000+ AI-generated pull requests in a single week — making it one of the clearest public benchmarks for what "agent-ready" means at scale. The difference between Stripe and most codebases isn't just tooling: it's the structural properties that let agents make changes confidently without breaking things.

This assessment scores those structural properties. A score of 70+ means agents can do meaningful, autonomous work. Below 50 means the foundational work of making the codebase navigable, testable, and documented needs to come first.

---

## Critical Findings
[List any dimensions scoring below 40, with the specific gap and why it blocks agent work]

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

AI agents are most effective in codebases where:
- **Tests catch mistakes** — an agent can make a change and know immediately if something broke
- **Docs reduce guessing** — CLAUDE.md and architecture docs mean agents don't have to infer intent
- **Small files reduce context pressure** — agents work best when a change fits in a single focused file
- **Types prevent silent failures** — strict types make agent mistakes compile errors, not runtime surprises
- **Conventions are automated** — agents can't accidentally violate style rules that are enforced by tooling

The score above reflects where this codebase stands today. Each point in the Improvement Roadmap is a concrete step toward the kind of codebase where agents ship production-quality code autonomously.

---
*Generated by codebase-readiness skill — claude-code-workflows*
```

---

## Phase 5: Offer to Save Report

After presenting the report, ask:

> "Would you like me to save this assessment as `AGENT_READY_ASSESSMENT.md` in the project root? It can serve as a baseline for tracking improvements over time and is useful for sharing with your team."

If the user confirms, write the full report to `AGENT_READY_ASSESSMENT.md` in the current directory.
