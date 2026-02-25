# Agent-Ready Codebase Assessment

**Does your codebase support AI agent work — or fight against it?**

This plugin runs a scored assessment of your repo across 8 dimensions and tells you exactly where you stand, framed against the benchmark of engineering teams shipping 1,000+ AI-generated pull requests per week.

The result is a score (0-100), a band rating, and a concrete improvement roadmap. Not opinions — evidence gathered from your actual codebase.

## Installation

```
/plugin marketplace add dgalarza/claude-code-workflows
/plugin install codebase-readiness@dgalarza-workflows
```

## Usage

From any project directory:

```
/codebase-readiness
```

The assessment spawns 4 parallel agents, scores all 8 dimensions using language-specific rubrics, and produces a full report. Takes about 10 minutes. Optionally saves the report as `AGENT_READY_ASSESSMENT.md` for sharing with your team.

## Score Bands

| Score  | Band             | What it means                                  |
|--------|------------------|------------------------------------------------|
| 85–100 | Agent-Ready      | Supports autonomous agent work                 |
| 70–84  | Agent-Assisted   | Agents work well with human oversight          |
| 50–69  | Agent-Supervised | Agents need heavy review before merging        |
| 30–49  | Agent-Caution    | Foundational improvements needed first         |
| 0–29   | Not Agent-Ready  | Significant investment required                |

## What Gets Scored

8 dimensions, weighted by language (dynamic languages like Ruby and Python weight tests higher; static languages like TypeScript and Go weight type safety higher):

| Dimension                 | What it measures                                                        |
|---------------------------|-------------------------------------------------------------------------|
| Test Foundation           | Coverage, quality, test-to-code ratio, mutation testing                 |
| Documentation & Context   | CLAUDE.md, ARCHITECTURE.md, ADRs, topic docs                           |
| Code Clarity              | File size, naming, filesystem as interface, catch-all directories       |
| Architecture Clarity      | Domain boundary visibility in the file tree, not just conceptual DDD    |
| Type Safety               | Strict types, semantic type names, database-level invariants            |
| Consistency & Conventions | Linting, formatting, custom architectural linters                       |
| Feedback Loops            | CI speed, ephemeral environments, parallel dev capability               |
| Change Safety             | Coupling, test isolation, PR size patterns                              |

## Architecture

The skill uses a **reference file pattern** for extensibility:

- **Dimension files** (`references/dimensions/`) define *what* to assess and *how* to score — the methodology. These are language-agnostic and rarely change.
- **Language files** (`references/languages/`) carry all language-specific tooling, commands, and scoring criteria. Adding support for a new language means adding one file.

During assessment, the orchestrator detects the primary language, loads the appropriate reference files, and composes prompts for 4 general-purpose agents that run in parallel. Each agent receives the relevant dimension guides plus the full language file.

## Why the Score Matters

The best AI-assisted engineering teams don't just have good prompts — they have codebases that make agent output cheaply verifiable. Fast CI, strict types, comprehensive tests, clear documentation: these are what let agents iterate quickly without constant human review.

The score measures how well your codebase satisfies that condition. The improvement roadmap tells you what to fix first.

Benchmarks show agentic coding can deliver 20x+ productivity — but only when the setup is right. This assessment tells you where your setup stands.

## Want Help Improving Your Score?

Built by [Damian Galarza](https://www.damiangalarza.com), a Claude Code specialist who helps engineering teams close the gap between having AI tools and actually using them well.

If your assessment surfaces gaps you want to fix faster, the [AI Workflow Enablement Program](https://www.damiangalarza.com/services/ai-enablement/) is a structured engagement that works through exactly this.
