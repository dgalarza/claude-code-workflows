# Agent-Ready Codebase Assessment

**Does the codebase support AI agent work, or fight it?**

This plugin scores a repository across 8 dimensions and reports where it stands, framed against teams shipping 1,000+ AI-generated pull requests per week.

The result is a score (0-100), a band rating, and a concrete improvement roadmap. Evidence comes from the repository, not from opinions.

Start at the landing page: [codebase readiness](https://www.damiangalarza.com/codebase-readiness/).

## Install

From this repository, after the marketplace is added:

```bash
/plugin marketplace add dgalarza/agent-skills
/plugin install codebase-readiness@dgalarza-agent-skills
```

```bash
npx skills add dgalarza/agent-skills --skill codebase-readiness
```

These commands are the GitHub install path. The landing page is the supported way to get the assessment.

## Usage

From a project directory, ask the agent to run the codebase-readiness assessment.

The skill runs four assessment passes. It launches them together when the runtime can run subagents, and runs them one after another in the current agent when it cannot. It scores all 8 dimensions with language-specific rubrics and produces a report. Optionally save the report as `AGENT_READY_ASSESSMENT.md`.

## Score Bands

| Score  | Band             | What it means                                  |
|--------|------------------|------------------------------------------------|
| 85–100 | Agent-Ready      | Supports autonomous agent work                 |
| 70–84  | Agent-Assisted   | Agents work well with human oversight          |
| 50–69  | Agent-Supervised | Agents need heavy review before merging        |
| 30–49  | Agent-Caution    | Foundational improvements needed first         |
| 0–29   | Not Agent-Ready  | Significant investment required                |

## What Gets Scored

Weights depend on language. Dynamic languages such as Ruby and Python weight tests higher. Static languages such as TypeScript, Go, and Rust weight type safety higher.

| Dimension                 | What it measures                                                        |
|---------------------------|-------------------------------------------------------------------------|
| Test Foundation           | Coverage, quality, test-to-code ratio, mutation testing                 |
| Documentation & Context   | Canonical agent instructions, ARCHITECTURE.md, domain context, ADRs, topic docs |
| Code Clarity              | File size, naming, catch-all directories, complexity/duplication/dead-code gate coverage |
| Architecture Clarity      | Domain boundary visibility in the file tree, not just conceptual DDD    |
| Type Safety               | Strict types, semantic type names, database-level invariants            |
| Consistency & Conventions | Linting, formatting, custom architectural linters, lint-debt baseline treatment |
| Feedback Loops            | CI speed, ephemeral environments, actionable and reproducible quality-gate feedback |
| Change Safety             | Coupling, migrations, feature flags, CI blocking new/worsened debt vs a governed baseline |

## Layout

The skill lives at `skills/codebase-readiness/`. This plugin directory is a thin manifest. `skills/codebase-readiness` here is a symlink to that canonical skill, which Claude Code copies into the plugin cache.

- **Dimension files** (`references/dimensions/`) define what to assess and how to score.
- **Language files** (`references/languages/`) carry language-specific tooling and criteria.
- **Shared references** (`references/quality-gates.md`) cover regression-aware quality gates. Reconnaissance assigns one Gate Maturity Level (L0-L4). Four dimensions each score a distinct slice so nothing is double-counted. Top-band credit requires CI that blocks new or worsened debt.

## Next step

If Documentation & Context is a weak dimension, [agent-ready](https://www.damiangalarza.com/agent-ready/) scaffolds AGENTS.md, ARCHITECTURE.md, domain-aware docs, and documentation checks. Claude Code 2.1.277+ reads AGENTS.md directly. Existing CLAUDE.md files stay in place.

## Want help improving the score?

Built by [Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=codebase-readiness).

[What each dimension means](https://www.damiangalarza.com/codebase-readiness/?utm_source=github&utm_medium=readme&utm_campaign=codebase-readiness)

If the assessment surfaces gaps to fix with a team, a [Foundation Sprint](https://www.damiangalarza.com/services/?utm_source=github&utm_medium=readme&utm_campaign=codebase-readiness) ships one foundation piece in two weeks, with the option to continue on a Production AI retainer.
