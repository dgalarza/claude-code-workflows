# Domain Knowledge Template

Use this template when generating a DOMAIN.md. Seed sections by scanning model names, entity types, and README content from the codebase. Mark thin definitions for team review rather than leaving them blank.

---

```markdown
# Domain Knowledge

<!-- This file documents the business domain this codebase implements.
     It answers "what does this system do?" not "how is the code structured?"
     For code architecture, see ARCHITECTURE.md.
     Maintainers: update this when new domain concepts are introduced in code. -->

## Glossary

Business terms the code implements. Not code terms -- if it only exists in code and has no business meaning, it belongs in ARCHITECTURE.md.

- **[Term]** -- [Definition in 1-2 sentences. What is this in the real world?] Maps to `[model_or_class_name]` in codebase.
- **[Term]** -- [Definition.] Maps to `[model_or_class_name]` in codebase.
- **[Term]** -- [Definition.] <!-- TODO: needs domain expert review -->

## Core Workflows

Key business processes the system models. Describe what happens from a business perspective, not implementation details.

### [Workflow Name]
- **Trigger:** [What initiates this process -- e.g., "A creator connects their YouTube channel"]
- **What happens:** [The business steps -- e.g., "Channel metrics are synced, historical videos are imported, an initial performance report is generated"]
- **Outcome:** [The end state -- e.g., "Creator has a dashboard with channel analytics and content recommendations"]
- **Key models:** `[Model1]`, `[Model2]`, `[Model3]`

### [Workflow Name]
- **Trigger:** [What initiates this]
- **What happens:** [Business steps]
- **Outcome:** [End state]
- **Key models:** `[Model1]`, `[Model2]`

## Domain Relationships

How major business concepts relate to each other. Write in plain English.

- [Relationship 1 -- e.g., "A Creator has many Channels. Each Channel has many Videos."]
- [Relationship 2 -- e.g., "A Video has one Performance Report. Reports are regenerated daily from platform analytics."]
- [Relationship 3 -- e.g., "Sponsors are matched to Creators based on audience overlap scores."]

## Regulatory / Compliance Context

<!-- Optional: remove this section if the domain has no regulatory requirements. -->

Industry-specific rules the code must respect. These constraints explain why certain things work the way they do.

- [Rule 1 -- e.g., "OAuth tokens must be encrypted at rest per platform API terms of service"]
- [Rule 2 -- e.g., "User analytics data must be anonymized after 90 days per privacy policy"]
- [Rule 3 -- e.g., "API rate limits must be respected -- YouTube Data API v3 allows 10,000 quota units per day"]
```

---

## Template Notes

**This documents business concepts, not code patterns.** Code architecture, module boundaries, and technical invariants go in ARCHITECTURE.md. DOMAIN.md answers "what does the product do and why?" -- the knowledge that lives in domain experts' heads and product docs, not in the code itself.

**Keep glossary entries to 2-3 sentences max.** If a concept needs a full explanation, link to a dedicated doc in `docs/references/`. The glossary is a quick-reference lookup, not a textbook.

**Link to code when helpful, but focus on the "what" and "why", not the "how."** Including model names and service names helps agents navigate the codebase. But the definition should make sense to someone who has never read the code.

**Update when new domain concepts are introduced in code.** If a PR adds a new model that represents a business concept, DOMAIN.md should get an entry. Treat it like updating a schema migration -- part of the change, not a follow-up task.

**Engineers who join should be able to read this and understand what the product does,** not just how the code is structured. This is the file you wish existed on your first week.

**Even a partially-filled DOMAIN.md is better than nothing.** Bootstrap it with what you can discover from model names, database schemas, and the README. Mark gaps with `<!-- TODO: needs domain expert review -->` for the team to fill in. A stub with real terms and thin definitions beats a perfect document that never gets written.

**This file is especially valuable for AI agents working in the codebase.** Agents can reference it to understand business intent behind code changes, write more accurate tests, and avoid violating domain rules they would otherwise have no way to discover.
