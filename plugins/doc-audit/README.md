# doc-audit

Audit codebase documentation for accuracy, completeness, and freshness against actual code. Auto-fixes small discrepancies, reports structural changes.

This is the **maintenance companion** to [agent-ready](../agent-ready/). While agent-ready *scaffolds* documentation, doc-audit *keeps it accurate* as code evolves.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "doc-audit"

# Or via Claude marketplace
/plugin install doc-audit@dgalarza-workflows
```

## Usage

```
/doc-audit              # Read-only audit, generates a report
/doc-audit fix          # Audit + auto-fix safe issues + commit
/doc-audit full         # Audit + fix + improvement roadmap
```

## Modes

| Mode | What It Does | Modifies Files? |
|------|-------------|-----------------|
| **audit** (default) | Scans docs against code, reports findings by severity | No |
| **fix** | Runs audit, auto-fixes safe issues (paths, ports, counts, links), commits changes | Yes |
| **full** | Runs fix, then generates a prioritized improvement roadmap | Yes |

## What It Checks

doc-audit evaluates four dimensions:

- **Completeness** -- Are expected docs present? (AGENTS.md, ARCHITECTURE.md, ADRs, docs/)
- **Accuracy** -- Do file paths, ports, commands, and counts in docs match actual code?
- **Freshness** -- Have docs been updated alongside code changes?
- **Coherence** -- Are there broken links, contradictions, or unnecessary duplication?

Each finding is categorized as Critical (actively misleading), Warning (stale/incomplete), or Info (minor).

## Example Output

```
# Documentation Audit Report

Date: 2026-03-27
Mode: audit
Codebase: my-project

## Summary

| Dimension    | Status | Findings   |
|--------------|--------|------------|
| Completeness | pass   | 1 findings |
| Accuracy     | fail   | 3 findings |
| Freshness    | warn   | 2 findings |
| Coherence    | pass   | 0 findings |

## Critical Findings

1. ARCHITECTURE.md references `packages/workers/` which no longer exists (deleted in abc123)
2. AGENTS.md says gateway runs on port 3001 but docker-compose.yml uses 4001
3. Build command `pnpm build:all` doesn't exist in package.json scripts

## Warnings

1. AGENTS.md last updated 18 days ago, 12 commits since then
2. No ADR for the migration from Express to Hono (committed 2 weeks ago)
```

## What fix Mode Auto-Corrects

- File paths in codemap that moved to a new location
- Port numbers that changed in docker-compose or .env
- Counts in tables (agents, tools, packages) that drifted
- Missing entries in docs/README.md index
- Broken relative links where the target file was renamed
- References to deleted files/directories

Issues requiring human judgment (new feature docs, architectural rewrites) are reported but not auto-fixed.

## Works With Any Project

doc-audit auto-detects project type (Node, Ruby, Python, Go, Rust, Java) and adjusts its checks accordingly. It applies monorepo-specific checks when it detects Turborepo, Nx, Lerna, or workspace configs.

No configuration needed.

## Relationship to agent-ready

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| [agent-ready](../agent-ready/) | Scaffold documentation from scratch | New project or first-time setup |
| **doc-audit** | Maintain documentation accuracy | Ongoing, after code changes |

**Recommended workflow:**
1. Run `agent-ready` to scaffold initial docs
2. Run `doc-audit` periodically to catch drift
3. Run `doc-audit fix` to auto-correct safe issues
4. Run `doc-audit full` quarterly for a comprehensive review

## Built By

[Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=doc-audit). If your team needs help beyond documentation -- architecture, test infrastructure, AI workflow adoption -- check out the [AI Workflow Enablement Program](https://www.damiangalarza.com/services/ai-enablement/?utm_source=github&utm_medium=readme&utm_campaign=doc-audit).
