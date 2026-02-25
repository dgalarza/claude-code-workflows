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
ls package.json Gemfile pyproject.toml go.mod requirements.txt pom.xml build.sbt 2>/dev/null
cat package.json 2>/dev/null | grep '"name"\|"main"\|"scripts"' | head -5
head -5 Gemfile 2>/dev/null
head -5 pyproject.toml 2>/dev/null
head -3 go.mod 2>/dev/null
head -5 build.sbt 2>/dev/null

# Size metrics
git rev-list --count HEAD 2>/dev/null || echo "Not a git repo or no commits"
git shortlog -sn HEAD 2>/dev/null | wc -l
find . -name "*.rb" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.scala" -o -name "*.java" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v vendor | grep -v target | grep -v spec | grep -v test | wc -l

# Test file ratio
find . -name "*_spec*" -o -name "*_test*" -o -name "*.spec.*" -o -name "*.test.*" -o -name "test_*.py" -o -name "*Spec.scala" -o -name "*Test.scala" -o -name "*Suite.scala" 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v target | wc -l

# CI/CD presence
ls .github/workflows/ .circleci/ .buildkite/ .gitlab-ci.yml 2>/dev/null

# CLAUDE.md
find . -name "CLAUDE.md" 2>/dev/null | grep -v node_modules | grep -v .git
find . -name "CLAUDE.md" -exec wc -l {} \; 2>/dev/null | grep -v node_modules

# Linting/formatting configs
ls .eslintrc* .rubocop.yml .flake8 ruff.toml .golangci.yml .prettierrc* .scalafmt.conf .scalafix.conf 2>/dev/null

# README
ls README.md README.rst README.txt 2>/dev/null
wc -l README.md 2>/dev/null
```

After running these commands, output a formatted **Codebase Snapshot**:

```
## Codebase Snapshot: [Project Name]

- **Primary language/framework**: [detected]
- **Language tier**: [statically-typed | dynamically-typed | gradually-typed]
  - Statically-typed: TypeScript, Go, Java, Scala, Rust, C#, Kotlin
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

Determine `PRIMARY_LANGUAGE` (ruby, python, typescript, javascript, go, java, or scala) and `LANGUAGE_TIER` (statically-typed, dynamically-typed, or gradually-typed) from the snapshot. These values drive which language reference file to load.

---

## Phase 2: Launch 4 Assessment Agents in Parallel

### Prompt Composition

Each agent receives a composed prompt built from reference files. The process:

1. **Read the language file** — `references/languages/{PRIMARY_LANGUAGE}.md` (include the entire file in each agent prompt)
2. **Read the dimension files** — each agent gets its relevant dimension files from `references/dimensions/`
3. **Compose the prompt** — role preamble + codebase snapshot + dimension content + language content + output instructions

Use the Read tool to load each reference file, then include the content inline in the agent prompts.

### Agent Prompts

Send a **single message** with **4 Agent tool calls** (subagent_type: `general-purpose`) to launch all agents simultaneously. Each agent gets the following composed prompt structure:

---

**Agent 1: Test & CI Agent**

Dimension files to read and include:
- `references/dimensions/test-foundation.md`
- `references/dimensions/feedback-loops.md`

Prompt:
```
You are a senior engineering consultant specializing in test infrastructure and developer feedback loops. Your role is to assess how well a codebase's testing and CI/CD setup supports autonomous AI agent work.

Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

## Assessment Instructions

Use the dimension guides and language-specific criteria below to assess two dimensions: **Test Foundation** and **Feedback Loops**. Run the evidence-gathering commands from both the dimension guides and the language file to collect data. Score each dimension 0-100 following the scoring bands, then apply any score modifiers.

### Dimension Guide: Test Foundation

[INSERT CONTENT OF references/dimensions/test-foundation.md]

### Dimension Guide: Feedback Loops

[INSERT CONTENT OF references/dimensions/feedback-loops.md]

### Language-Specific Criteria

[INSERT CONTENT OF references/languages/{PRIMARY_LANGUAGE}.md]

Return the full scored assessment for both dimensions in the output format specified in each dimension guide. Be specific — reference actual files, counts, and statistics.
```

---

**Agent 2: Documentation Agent**

Dimension files to read and include:
- `references/dimensions/documentation.md`

Prompt:
```
You are a senior engineering consultant specializing in developer experience and knowledge management. Your role is to assess how well a codebase's documentation enables AI agents to work autonomously without constant human clarification.

Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

## Assessment Instructions

Use the dimension guide and language-specific criteria below to assess one dimension: **Documentation & Context**. Run the evidence-gathering commands to collect data. Score 0-100 following the scoring bands.

### Dimension Guide: Documentation & Context

[INSERT CONTENT OF references/dimensions/documentation.md]

### Language-Specific Criteria

[INSERT CONTENT OF references/languages/{PRIMARY_LANGUAGE}.md]

Return the full scored assessment in the output format specified in the dimension guide. Be specific — reference actual files found. CLAUDE.md is the most important artifact for agent-readiness — give it special attention.
```

---

**Agent 3: Code Quality Agent**

Dimension files to read and include:
- `references/dimensions/code-clarity.md`
- `references/dimensions/consistency.md`

Prompt:
```
You are a senior engineering consultant specializing in code quality and developer tooling. Your role is to assess how navigable and consistent a codebase is for AI agents — agents perform better in codebases with small, focused files and enforced conventions.

Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

## Assessment Instructions

Use the dimension guides and language-specific criteria below to assess two dimensions: **Code Clarity** and **Consistency & Conventions**. Run the evidence-gathering commands from both the dimension guides and the language file to collect data. Score each dimension 0-100 following the scoring bands.

### Dimension Guide: Code Clarity

[INSERT CONTENT OF references/dimensions/code-clarity.md]

### Dimension Guide: Consistency & Conventions

[INSERT CONTENT OF references/dimensions/consistency.md]

### Language-Specific Criteria

[INSERT CONTENT OF references/languages/{PRIMARY_LANGUAGE}.md]

Return the full scored assessment for both dimensions in the output format specified in each dimension guide. Be specific — reference actual files and line counts.
```

---

**Agent 4: Architecture Agent**

Dimension files to read and include:
- `references/dimensions/type-safety.md`
- `references/dimensions/architecture-clarity.md`
- `references/dimensions/change-safety.md`

Prompt:
```
You are a senior engineering consultant specializing in software architecture and developer safety systems. Your role is to assess how safely and predictably AI agents can modify a codebase — the guard rails that prevent agent mistakes vary by language: type systems for statically-typed languages, contract/test systems for dynamically-typed ones.

Here is the Codebase Snapshot gathered by the orchestrator:

[INSERT FULL CODEBASE SNAPSHOT]

LANGUAGE_TIER: [static | dynamic | gradual]
PRIMARY_LANGUAGE: [Ruby | Python | TypeScript | Go | etc.]

## Assessment Instructions

Use the dimension guides and language-specific criteria below to assess three dimensions: **Type Safety**, **Architecture Clarity**, and **Change Safety**. Run the evidence-gathering commands from both the dimension guides and the language file to collect data. Score each dimension 0-100 following the scoring bands, then apply any score modifiers. Apply the language-appropriate Type Safety rubric based on LANGUAGE_TIER.

### Dimension Guide: Type Safety

[INSERT CONTENT OF references/dimensions/type-safety.md]

### Dimension Guide: Architecture Clarity

[INSERT CONTENT OF references/dimensions/architecture-clarity.md]

### Dimension Guide: Change Safety

[INSERT CONTENT OF references/dimensions/change-safety.md]

### Language-Specific Criteria

[INSERT CONTENT OF references/languages/{PRIMARY_LANGUAGE}.md]

Return the full scored assessment for all three dimensions in the output format specified in each dimension guide. Be specific — reference actual files, line counts, and git statistics.
```

---

Wait for all 4 agents to complete before proceeding.

---

## Phase 3: Score Calculation

Weights are **language-adaptive**. Select the appropriate table based on `LANGUAGE_TIER` from the Codebase Snapshot.

### Dynamically-typed languages (Ruby, Python, JavaScript)

In dynamic languages, tests are the type system. Test Foundation carries more weight; Type Safety reflects contracts and interface clarity, not a type checker.

| Dimension                 | Weight | Agent Score | Weighted |
|---------------------------|--------|-------------|----------|
| Test Foundation           | 25%    | XX/100      | XX       |
| Documentation & Context   | 15%    | XX/100      | XX       |
| Code Clarity              | 15%    | XX/100      | XX       |
| Architecture Clarity      | 15%    | XX/100      | XX       |
| Feedback Loops            | 10%    | XX/100      | XX       |
| Type Safety*              | 10%    | XX/100      | XX       |
| Consistency & Conventions | 5%     | XX/100      | XX       |
| Change Safety             | 5%     | XX/100      | XX       |

*Type Safety for dynamic languages = contracts (dry-rb, Pydantic), ActiveRecord validations, Result pattern consistency. NOT penalized for absence of a type checker.

### Statically-typed languages (TypeScript, Go, Java, Scala, Rust)

| Dimension                 | Weight | Agent Score | Weighted |
|---------------------------|--------|-------------|----------|
| Type Safety               | 20%    | XX/100      | XX       |
| Test Foundation           | 15%    | XX/100      | XX       |
| Documentation & Context   | 15%    | XX/100      | XX       |
| Code Clarity              | 15%    | XX/100      | XX       |
| Architecture Clarity      | 15%    | XX/100      | XX       |
| Feedback Loops            | 10%    | XX/100      | XX       |
| Consistency & Conventions | 5%     | XX/100      | XX       |
| Change Safety             | 5%     | XX/100      | XX       |

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

## Want Help Moving the Needle?

This assessment was built by [Damian Galarza](https://www.damiangalarza.com) — a Claude Code specialist who helps engineering teams close the gap between having AI tools and actually using them well.

If your score surfaced gaps you want to fix, the **AI Workflow Enablement Program** is a structured 3–8 week engagement that works through exactly this: codebase readiness, team conventions, shared skills, and workshops built on your actual codebase.

**[See the full program →](https://www.damiangalarza.com/services/ai-enablement/)**

---

## Dimension Details

[Insert full agent reports for all 8 dimensions here, grouped by agent]

### Test Foundation & Feedback Loops
[Test & CI agent full report]

### Documentation & Context
[Documentation agent full report]

### Code Clarity & Consistency
[Code Quality agent full report]

### Type Safety, Architecture & Change Safety
[Architecture agent full report]

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
