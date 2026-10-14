# agent-ready

Make a codebase agent-ready by scaffolding AGENTS.md, ARCHITECTURE.md, and a `docs/` structure that follows progressive disclosure, installing a regression-aware quality gate, and recommending project-local skills for the detected stack.

This is the remediation companion to [codebase readiness](https://www.damiangalarza.com/codebase-readiness/). Codebase readiness scores the repository. Agent-ready closes the documentation and quality-gate gaps.

Start at the landing page: [agent-ready](https://www.damiangalarza.com/agent-ready/).

## Install

From this repository, after the marketplace is added:

```bash
/plugin marketplace add dgalarza/agent-skills
/plugin install agent-ready@dgalarza-agent-skills
```

```bash
npx skills add dgalarza/agent-skills --skill agent-ready
```

These commands are the GitHub install path. The landing page is the supported way to get the skill.

## Modes

| Mode | What it does | Example prompt |
|------|-------------|----------------|
| **scaffold** | Full setup: docs/ structure, ARCHITECTURE.md, AGENTS.md, documentation check, quality gate | "Make this codebase agent-ready" |
| **architecture** | Generate ARCHITECTURE.md from the actual codebase | "Create an ARCHITECTURE.md" |
| **agents-md** | Create or refactor AGENTS.md for progressive disclosure | "Set up AGENTS.md" |
| **quality-gates** | Install a regression-aware quality gate: native complexity, duplication, and dead-code checks, a reviewed baseline, merge-base-aware CI, docs, and tests | "Set up quality gates" |
| **migrate** | Upgrade a legacy agent-ready scaffold to the current domain-context, ADR, and documentation-check contract | "Migrate our agent-ready docs" |
| **audit** | Check existing agent-readiness artifacts and the quality gate for staleness, coherence, and governance | "Are my agent docs up to date?" |

## Quality gates

Documentation tells an agent what good looks like. A quality gate stops it from shipping the opposite. The `quality-gates` mode installs a regression-aware gate: legacy debt stays in a baseline, and any change that adds complexity, duplication, or dead code — or makes a baselined finding worse — fails CI.

| Piece | Detail |
|-------|--------|
| Checks | The language's native tools. Native baseline or diff modes are used where they exist; otherwise a stdlib engine (`assets/quality-gate.py`) fingerprints findings so line-number churn does not look like new debt |
| Commands | `report` / `check` / `baseline --prune`, identical locally and in CI |
| Baseline | Created only with a written `--reason` and a human `--approve --reviewed-by`. `check` fails while it is unreviewed. Refused in CI. Stale entries fail until pruned |
| CI | Merge-base-aware job that annotates findings on the pull request diff |
| Docs | `docs/guides/quality-gates.md` plus Definition of Done directives in AGENTS.md |
| Tests | A self-test proving a clean tree passes, synthetic debt fails, and stale entries are pruned |

## Agent instructions

The plugin generates **AGENTS.md** as the shared instruction file. Claude Code reads AGENTS.md directly starting with version 2.1.277, so do not add a CLAUDE.md symlink. Preserve an existing CLAUDE.md. If both files exist and disagree, say so.

The skill source is `skills/agent-ready/`. This plugin directory is a thin manifest; `skills/agent-ready` here symlinks to that canonical skill.

## Recommended workflow

1. Score the repo with [codebase readiness](https://www.damiangalarza.com/codebase-readiness/).
2. Run agent-ready to fix documentation and structure.
3. If the Gate Maturity Level is L0-L2, run agent-ready in **quality-gates** mode.
4. Re-run the assessment to measure the change.

If `AGENT_READY_ASSESSMENT.md` exists, agent-ready reads it and suggests which mode to run first.

## Want help beyond documentation?

Built by [Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=agent-ready).

A [Foundation Sprint](https://www.damiangalarza.com/services/?utm_source=github&utm_medium=readme&utm_campaign=agent-ready) is two weeks on the highest-leverage problem in the AI stack, followed by a Production AI retainer if the work should continue.
