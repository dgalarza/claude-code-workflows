# agent-ready

Make a codebase agent-ready by scaffolding AGENTS.md, ARCHITECTURE.md, and docs/ structure following progressive disclosure patterns, installing a regression-aware quality gate, and recommending project-local skills for the detected stack.

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
| **scaffold** | Full setup: docs/ structure, ARCHITECTURE.md, AGENTS.md, CLAUDE.md symlink, starter ADR, quality gate | "Make this codebase agent-ready" |
| **architecture** | Generate ARCHITECTURE.md from actual codebase analysis | "Create an ARCHITECTURE.md" |
| **agents-md** | Create or refactor AGENTS.md for progressive disclosure, create CLAUDE.md symlink | "Set up AGENTS.md" |
| **quality-gates** | Install a regression-aware quality gate: native complexity/duplication/dead-code checks, reviewed baseline, merge-base-aware CI, docs, tests | "Set up quality gates", "baseline our tech debt" |
| **audit** | Check existing agent-readiness artifacts and the quality gate for staleness, coherence, and governance | "Are my agent docs up to date?" |

## Quality Gates

Documentation tells agents what good looks like; a quality gate stops them from shipping the opposite. The `quality-gates` mode installs a **regression-aware** gate: legacy debt is inventoried in a baseline and allowed to stay, while any PR that adds new complexity, duplication, or dead code -- or makes a baselined finding worse -- fails CI.

What gets installed in your repo:

| Piece | Detail |
|-------|--------|
| Checks | The language's native tools (ESLint/knip/jscpd, RuboCop/flay/debride, ruff/pylint/vulture, golangci-lint, detekt/PMD, clippy, PHPStan/phpmd). Native baseline or diff modes are used where they exist; otherwise a small stdlib engine (`scripts/quality-gate.py`) fingerprints findings so line-number churn does not create false "new" debt |
| Commands | `report` / `check` / `baseline --prune`, identical locally and in CI, exposed through the project's task runner |
| Baseline | Created only with a written `--reason` and a human `--approve --reviewed-by`; `check` fails while it is unreviewed; refused in CI; CODEOWNERS-protected. Stale entries fail `check` until pruned, so the baseline only shrinks |
| CI | Merge-base-aware job that annotates findings on the PR diff. No `continue-on-error` |
| Docs | `docs/guides/quality-gates.md` plus Definition of Done and directives in AGENTS.md |
| Tests | A self-test proving a clean tree passes, synthetic debt fails, and stale entries are pruned |

The pattern is documented in `references/quality-gates-pattern.md` with adapter recipes per language. The engine template has its own unit tests in `tests/`.

## Project Skill Recommendations

Agent-ready inspects tracked manifests and configuration for strong stack signals and recommends a curated set of skills:

| Detected Project | Recommended Skill | Source |
|------------------|-------------------|--------|
| React web | `vercel-react-best-practices` | [Vercel](https://github.com/vercel-labs/agent-skills) |
| React Native or Expo | `vercel-react-native-skills` | [Vercel](https://github.com/vercel-labs/agent-skills) |
| Angular | `angular-developer` | [Angular](https://github.com/angular/angular) |
| Svelte | `svelte-core-bestpractices` | [Svelte](https://github.com/sveltejs/ai-tools) |
| Mastra | `mastra` | [Mastra](https://github.com/mastra-ai/skills) |
| FastAPI | `fastapi` | [FastAPI](https://github.com/fastapi/fastapi) |
| Laravel | `laravel-best-practices` | [Laravel](https://github.com/laravel/boost) |
| Supabase | `supabase` | [Supabase](https://github.com/supabase/agent-skills) |
| Stripe | `stripe-best-practices` | [Stripe](https://github.com/stripe/ai) |
| Cloudflare Workers | `workers-best-practices` | [Cloudflare](https://github.com/cloudflare/skills) |
| Terraform | `terraform-style-guide` | [HashiCorp](https://github.com/hashicorp/agent-skills) |

For repositories with a clearly user-facing browser UI, it separately offers `frontend-design` from Anthropic and `web-design-guidelines` from Vercel as optional additions.

Agent-ready checks project-local installations first, groups missing recommendations into one prompt, and waits for confirmation. Confirmed skills are installed from the repository root with `npx skills add` in project scope; optional skills are not selected by default, and nothing is installed globally or without consent.

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
3. If the assessment's Gate Maturity Level is L0-L2, run agent-ready in **quality-gates** mode
4. Re-run the assessment to measure improvement

[What each dimension means and why it matters →](https://www.damiangalarza.com/codebase-readiness/?utm_source=github&utm_medium=readme&utm_campaign=agent-ready)

## Want Help Beyond Documentation?

Built by [Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=agent-ready). Documentation is one dimension. If your assessment surfaced gaps across test infrastructure, architecture, or team adoption, the [AI Workflow Enablement Program](https://www.damiangalarza.com/services/ai-enablement/?utm_source=github&utm_medium=readme&utm_campaign=agent-ready) works through all of it on your actual codebase.
