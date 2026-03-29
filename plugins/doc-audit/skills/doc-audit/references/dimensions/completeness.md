# Completeness Assessment

Evaluate whether the expected documentation artifacts exist and have meaningful content.

## Checklist

### Critical (must exist)

- [ ] **Entry point doc** -- AGENTS.md or CLAUDE.md exists at the project root
  - If both exist, CLAUDE.md should be a symlink to AGENTS.md
  - File should be non-empty and contain project-specific content (not just a template)
- [ ] **Setup instructions** -- Build, test, and run commands are documented somewhere (AGENTS.md, README.md, or docs/)

### Warning (should exist)

- [ ] **ARCHITECTURE.md** -- Codemap with directory descriptions, invariants, and boundaries
  - Should reference actual directories that exist on disk
  - Should name important files and types
- [ ] **docs/ directory** -- Structured documentation beyond root-level files
  - Should contain a README.md index
  - Should have at least one of: guides/, references/, decisions/
- [ ] **ADRs** -- Architecture Decision Records in docs/decisions/, docs/adr/, or docs/adrs/
  - At least one ADR should exist for non-trivial projects

### Info (nice to have)

- [ ] **Nested AGENTS.md** -- Major source directories have their own AGENTS.md with domain-specific context
- [ ] **DOMAIN.md** -- Business domain glossary and workflows in docs/DOMAIN.md
- [ ] **CONTRIBUTING.md** -- Contribution guidelines for external or team contributors
- [ ] **API documentation** -- Endpoint docs for projects that expose APIs

## Scoring

| Level | Criteria |
|-------|----------|
| Critical | No entry point doc (AGENTS.md/CLAUDE.md) or no build/test instructions |
| Warning | Missing ARCHITECTURE.md, no docs/ directory, no ADRs |
| Info | Missing nested docs, no DOMAIN.md, no CONTRIBUTING.md |

## Monorepo Considerations

For monorepos, also check:
- Each package/workspace has its own entry in the root ARCHITECTURE.md codemap
- Shared packages document their exports
- Root AGENTS.md explains the package structure and how packages relate
