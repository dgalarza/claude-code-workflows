# docs/ Directory Structure Template

Recommended documentation layout for agent-ready codebases. Adapt based on project size and needs.

---

```
docs/
├── README.md                          # Documentation index -- start here
├── architecture/                      # Design documents
│   ├── [feature-name].md              # Design doc for a specific feature or system
│   └── ...
├── guides/                            # How-to guides for common workflows
│   ├── setup.md                       # Development environment setup
│   ├── testing.md                     # Testing patterns and conventions
│   ├── deployment.md                  # Deployment process and checklist
│   └── [workflow-name].md             # Additional workflow guides as needed
├── references/                        # Reference material
│   ├── api.md                         # API documentation or pointers
│   ├── schemas.md                     # Data schemas and models
│   └── [topic].md                     # Other reference material
└── decisions/                         # Architecture Decision Records (ADRs)
    ├── 001-[decision-title].md        # First decision
    ├── 002-[decision-title].md        # Second decision
    └── ...
```

---

## docs/README.md Template

```markdown
# Documentation

Index of project documentation. Start here to find what you need.

## Architecture
- [ARCHITECTURE.md](../ARCHITECTURE.md) -- System overview, codemap, invariants, and boundaries

## Design Documents
- [docs/architecture/[name].md](./architecture/[name].md) -- [Brief description]

## Guides
- [Setup](./guides/setup.md) -- Development environment setup
- [Testing](./guides/testing.md) -- Testing patterns and conventions
- [Deployment](./guides/deployment.md) -- How to deploy

## References
- [API](./references/api.md) -- API documentation
- [Schemas](./references/schemas.md) -- Data models and schemas

## Decisions
Architecture Decision Records (ADRs) capture significant decisions and their rationale.

- [001 - [Title]](./decisions/001-[title].md) -- [One-line summary]
```

---

## ADR Template

```markdown
# [Number]. [Title]

**Date:** YYYY-MM-DD
**Status:** [Proposed | Accepted | Deprecated | Superseded by [link]]

## Context
[What is the issue motivating this decision?]

## Decision
[What is the change that we are proposing and/or doing?]

## Consequences
[What becomes easier or harder as a result of this decision?]

## Alternatives Considered
- [Alternative 1] -- [Why rejected]
- [Alternative 2] -- [Why rejected]
```

---

## Guidelines

**Start small.** Not every project needs every directory. Begin with:
1. `docs/README.md` (index)
2. `docs/guides/setup.md` (if setup is non-trivial)
3. `docs/decisions/` (start recording decisions now)

**Grow as needed.** Add guides and references when content would otherwise bloat CLAUDE.md or get duplicated across docs.

**Single source of truth.** Each topic lives in exactly one file. CLAUDE.md links point here. Do not duplicate content between docs and CLAUDE.md.

**ADRs are permanent.** Do not delete old ADRs. Mark them as Deprecated or Superseded. The history of decisions is valuable context for agents.
