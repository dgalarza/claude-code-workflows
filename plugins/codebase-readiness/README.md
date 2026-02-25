# Codebase Readiness Plugin

Score your codebase's readiness for autonomous AI agent work — framed around the Stripe benchmark of 1,000+ AI-generated pull requests per week.

## What It Does

Runs a **parallel multi-agent assessment** across 8 dimensions, producing a weighted score (0-100) with a band rating and actionable improvement roadmap.

### Score Bands

| Score   | Band              | Meaning                                    |
|---------|-------------------|--------------------------------------------|
| 85-100  | Agent-Ready       | Supports autonomous agent work             |
| 70-84   | Agent-Assisted    | Agents work well with human oversight      |
| 50-69   | Agent-Supervised  | Agents need heavy review before merging    |
| 30-49   | Agent-Caution     | Foundational improvements needed first     |
| 0-29    | Not Agent-Ready   | Significant investment required            |

### Dimensions Assessed (8 total)

| Dimension                 | Weight | Assessed By                |
|---------------------------|--------|----------------------------|
| Test Foundation           | 20%    | test-coverage-assessor     |
| Documentation & Context   | 15%    | documentation-assessor     |
| Code Clarity              | 15%    | code-clarity-assessor      |
| Type Safety               | 15%    | architecture-assessor      |
| Architecture Clarity      | 15%    | architecture-assessor      |
| Consistency & Conventions | 10%    | code-clarity-assessor      |
| Feedback Loops            | 5%     | test-coverage-assessor     |
| Change Safety             | 5%     | architecture-assessor      |

## Usage

From any project directory:

```
Run a codebase readiness assessment
```

Or use the skill directly:

```
/codebase-readiness
```

The assessment will:
1. Gather codebase metadata (language, size, CI config, documentation)
2. Launch 4 specialized agents in parallel to assess all 8 dimensions
3. Calculate a weighted score and assign a band rating
4. Present a full report with an improvement roadmap
5. Offer to save the report as `AGENT_READY_ASSESSMENT.md`

## Why This Matters

The score divorces the assessment from any individual's opinion — it's a structured evaluation against the same properties that let Stripe ship 1k+ AI-generated PRs per week. High-scoring reports are shareable artifacts for board decks and engineering reviews. The improvement roadmap maps directly to concrete engineering work.

## Installation

```bash
claude plugins install https://github.com/dgalarza/claude-code-workflows --plugin codebase-readiness
```

## Plugin Structure

```
plugins/codebase-readiness/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── skills/
│   └── codebase-readiness/
│       └── SKILL.md                  # Orchestrator
└── agents/
    ├── test-coverage-assessor.md     # Test Foundation + Feedback Loops
    ├── documentation-assessor.md     # Documentation & Context
    ├── code-clarity-assessor.md      # Code Clarity + Consistency
    └── architecture-assessor.md     # Type Safety + Architecture + Change Safety
```
