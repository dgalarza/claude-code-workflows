# Domain Knowledge Template

Use this template when generating a DOMAIN.md. Seed only workflows, relationships, and domain rules that code or existing documentation supports. Canonical terminology belongs in CONTEXT.md and is created only when terms are resolved.

---

```markdown
# Domain Knowledge

<!-- This file documents the business domain this codebase implements.
     It answers "what does this system do?" not "how is the code structured?"
     For code architecture, see ARCHITECTURE.md.
     Canonical terminology belongs in CONTEXT.md, created only once terms are resolved.
     Maintainers: update this when a workflow, relationship, or domain rule changes. -->

<!-- If CONTEXT.md exists, link it here. Do not duplicate its glossary in this file. -->

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

**Keep workflows and relationships concrete.** If a workflow cannot be supported by code or existing documentation, leave a review marker rather than inventing it.

**Canonical terminology belongs in `CONTEXT.md`.** Create that file lazily when a term is resolved. Keep definitions tight, record avoided synonyms there, and link to it from this file when it exists.

**Link to code when helpful, but focus on the "what" and "why", not the "how."** Including model names and service names helps agents navigate the codebase. But the explanation should make sense to someone who has never read the code.

**This file is especially valuable for AI agents working in the codebase.** Agents can reference it to understand business intent behind code changes, write more accurate tests, and avoid violating domain rules they would otherwise have no way to discover.
