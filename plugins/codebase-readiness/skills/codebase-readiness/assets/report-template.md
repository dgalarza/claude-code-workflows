# Agent-Ready Assessment: [Project Name]

## Overall Agent-Ready Score: XX/100
**Rating: [Band Name]**

[2-sentence interpretation — e.g., "This codebase can support AI agent work with human oversight on most changes. The test foundation and type system provide reasonable guard rails, but documentation gaps will cause agents to make incorrect assumptions about business intent."]

### Score Breakdown

Use the weight table matching the codebase's LANGUAGE_TIER from Phase 3. Fill in from agent results.

| Dimension                 | Weight | Score   | Weighted |
|---------------------------|--------|---------|----------|
| Test Foundation           | XX%    | XX/100  | XX.X     |
| Documentation & Context   | XX%    | XX/100  | XX.X     |
| Code Clarity              | XX%    | XX/100  | XX.X     |
| Type Safety               | XX%    | XX/100  | XX.X     |
| Architecture Clarity      | XX%    | XX/100  | XX.X     |
| Consistency & Conventions | XX%    | XX/100  | XX.X     |
| Feedback Loops            | XX%    | XX/100  | XX.X     |
| Change Safety             | XX%    | XX/100  | XX.X     |
| **TOTAL**                 | 100%   |         | **XX/100** |

---

## Language Context: [Primary Language]

> **For dynamically-typed languages (Ruby, Python, JavaScript, PHP) only — omit for TypeScript/Go/Java/Scala.**

This codebase is written in **[Language]**, a dynamically-typed language. The scoring framework adapts for this:

| Signal | [Language] equivalent |
|--------|----------------------|
| Type Safety (10%) | Contract systems ([dry-rb/Pydantic/PHPStan+Larastan/etc.]), validated interfaces, Form Requests, Result pattern |
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

## Start Fixing: agent-ready

If Documentation & Context scored below 60, the **agent-ready** companion plugin can close that gap now. It scaffolds CLAUDE.md, ARCHITECTURE.md, and a docs/ structure following progressive disclosure patterns, built on your actual codebase.

```
/plugin install agent-ready@dgalarza-workflows
```

It reads this assessment report and suggests which mode to run first based on your weakest dimensions.

---

## Want Help Moving the Needle?

This assessment was built by [Damian Galarza](https://www.damiangalarza.com?utm_source=codebase-readiness&utm_medium=report&utm_campaign=codebase-readiness) — a Claude Code specialist who helps engineering teams close the gap between having AI tools and actually using them well.

**[What each dimension means and how to interpret your score →](https://www.damiangalarza.com/codebase-readiness/?utm_source=codebase-readiness&utm_medium=report&utm_campaign=codebase-readiness)**

If your score surfaced gaps you want to fix, the **AI Workflow Enablement Program** is a structured 3–8 week engagement that works through exactly this: codebase readiness, team conventions, shared skills, and workshops built on your actual codebase.

**[See the full program →](https://www.damiangalarza.com/services/ai-enablement/?utm_source=codebase-readiness&utm_medium=report&utm_campaign=codebase-readiness)**

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

Each point in the Improvement Roadmap raises the verification limit — reducing manual review burden while increasing confidence in every agent-produced change.

---
*Generated by codebase-readiness skill — claude-code-workflows*
