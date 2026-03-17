# agent-ready

Make a codebase agent-ready by scaffolding AGENTS.md, ARCHITECTURE.md, and docs/ structure following progressive disclosure patterns.

This is the **remediation companion** to [codebase-readiness](../codebase-readiness/). While codebase-readiness *scores* how agent-ready your codebase is, agent-ready *fixes* the gaps by generating the documentation and structural artifacts that make a codebase legible to AI agents.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "agent-ready"

# Or via Claude marketplace
/plugin install agent-ready@dgalarza-workflows
```

## Modes

| Mode | What It Does | Example Prompt |
|------|-------------|----------------|
| **scaffold** | Full documentation setup: docs/ structure, ARCHITECTURE.md, AGENTS.md, CLAUDE.md symlink, starter ADR | "Make this codebase agent-ready" |
| **architecture** | Generate ARCHITECTURE.md from actual codebase analysis | "Create an ARCHITECTURE.md" |
| **agents-md** | Create or refactor AGENTS.md for progressive disclosure, create CLAUDE.md symlink | "Set up AGENTS.md" |
| **audit** | Check existing agent-readiness artifacts for staleness and coherence | "Are my agent docs up to date?" |

## Principles

Built on two key sources:

- **Harness Engineering (OpenAI)** -- repository as system of record, progressive disclosure, AGENTS.md as table of contents not encyclopedia, enforce invariants not implementations
- **matklad's ARCHITECTURE.md** -- bird's-eye codemap, name important modules, call out invariants (especially absences), point out boundaries

## AGENTS.md vs CLAUDE.md

This plugin generates **AGENTS.md** as the primary documentation file, which works with any AI coding agent that supports the AGENTS.md convention. For backward compatibility with Claude Code, it also creates **CLAUDE.md as a symlink** to AGENTS.md.

This approach ensures:
- Your documentation works with any AI coding agent
- Claude Code users have seamless compatibility
- You maintain a single source of truth (AGENTS.md)

## Integration with codebase-readiness

If an `AGENT_READY_ASSESSMENT.md` exists from a prior codebase-readiness assessment, agent-ready will read it and auto-suggest which mode to run first based on the weakest dimensions.

**Recommended workflow:**

1. Run [codebase-readiness](../codebase-readiness/) to score your repo and identify gaps
2. Run agent-ready to fix the documentation and structure gaps automatically
3. Re-run the assessment to measure improvement

[What each dimension means and why it matters →](https://www.damiangalarza.com/codebase-readiness/?utm_source=github&utm_medium=readme&utm_campaign=agent-ready)

## Want Help Beyond Documentation?

Built by [Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=agent-ready). Documentation is one dimension. If your assessment surfaced gaps across test infrastructure, architecture, or team adoption, the [AI Workflow Enablement Program](https://www.damiangalarza.com/services/ai-enablement/?utm_source=github&utm_medium=readme&utm_campaign=agent-ready) works through all of it on your actual codebase.
