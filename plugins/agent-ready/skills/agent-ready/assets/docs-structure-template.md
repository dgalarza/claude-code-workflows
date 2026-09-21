# docs/ Directory Structure Template

Recommended documentation layout for agent-ready codebases. Adapt based on project size and needs.

---

```
CONTEXT.md                             # Canonical domain glossary, created when terms are resolved
docs/
├── README.md                          # Documentation index -- start here
├── DOMAIN.md                          # Workflows, relationships, and compliance context (not a glossary)
├── architecture/                      # Design documents
│   ├── [feature-name].md              # Design doc for a specific feature or system
│   └── ...
├── guides/                            # How-to guides for common workflows
│   ├── setup.md                       # Development environment setup
│   ├── testing.md                     # Testing patterns and conventions
│   ├── deployment.md                  # Deployment process and checklist
│   ├── quality-gates.md               # Quality gate commands, thresholds, baseline protocol
│   └── [workflow-name].md             # Additional workflow guides as needed
├── references/                        # Reference material
│   ├── api.md                         # API documentation or pointers
│   ├── schemas.md                     # Data schemas and models
│   └── [topic].md                     # Other reference material
└── adr/                               # Architecture Decision Records, created when warranted
    ├── 0001-[decision-title].md
    ├── 0002-[decision-title].md
    └── ...
```

---

## docs/README.md Template

```markdown
# Documentation

Index of project documentation. Start here to find what you need.

## Architecture
- [ARCHITECTURE.md](../ARCHITECTURE.md) -- System overview, codemap, invariants, and boundaries

## Domain Knowledge
- [DOMAIN.md](./DOMAIN.md) -- Business workflows, relationships, and compliance context
- Add a `CONTEXT.md` link here only when `../CONTEXT.md` exists; it is the canonical business terms and vocabulary-to-avoid doc

## Design Documents
- [docs/architecture/[name].md](./architecture/[name].md) -- [Brief description]

## Guides
- [Setup](./guides/setup.md) -- Development environment setup
- [Testing](./guides/testing.md) -- Testing patterns and conventions
- [Deployment](./guides/deployment.md) -- How to deploy
- [Quality Gates](./guides/quality-gates.md) -- Regression-aware complexity, duplication, and dead-code checks

## References
- [API](./references/api.md) -- API documentation
- [Schemas](./references/schemas.md) -- Data models and schemas

## Decisions
Architecture Decision Records (ADRs) capture durable decisions and their rationale.

- [0001 - [Title]](./adr/0001-[title].md) -- [One-line summary]
```

---

## ADR Template

```markdown
# [Short title]

[One to three sentences explaining the context, decision, and why it was chosen.]
```

Add status, alternatives, or consequences only when they preserve non-obvious context.

---

## Guidelines

**Start small.** Not every project needs every directory. Begin with:
1. `docs/README.md` (index)
2. `docs/guides/setup.md` (if setup is non-trivial)
3. `CONTEXT.md` only after a domain term is resolved
4. `docs/adr/` only after a qualifying decision is made

**Grow as needed.** Add guides and references when content would otherwise bloat CLAUDE.md or get duplicated across docs.

**Single source of truth.** Each topic lives in exactly one file. CLAUDE.md links point here. Do not duplicate content between docs and CLAUDE.md.

**Create ADRs sparingly.** Write one only when all three are true: the decision is hard to reverse, surprising without context, and the result of a real trade-off. Do not delete ADRs once written; mark obsolete ones as Deprecated or Superseded.
