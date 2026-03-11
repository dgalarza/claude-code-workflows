# Architecture

## Design Philosophy

This repository treats the **repository as the system of record** for agent capabilities. Every skill, agent definition, and workflow lives in-repo as versioned, structured artifacts that agents can discover and reason about directly.

The architecture follows the principle of **progressive disclosure** — agents encounter a small, stable entry point (SKILL.md frontmatter) and are taught where to look next (the SKILL.md body, then references, then scripts and assets), rather than being overwhelmed up front.

## Component Map

### Plugin Marketplace (`.claude-plugin/marketplace.json`)

The single registry that maps plugin names to their source directories and versions. This is what Claude Code reads when users run `/plugin marketplace add` or `/plugin install`.

### Plugins (`plugins/`)

Each plugin is self-contained and independently installable. A plugin can contain one or more skills, agents, or commands.

```
plugins/<name>/
├── .claude-plugin/plugin.json   ← identity + version
├── README.md                    ← user-facing docs
└── skills/<skill-name>/
    ├── SKILL.md                 ← the skill itself
    ├── scripts/                 ← deterministic, executable code
    ├── references/              ← documentation loaded into context as needed
    └── assets/                  ← files used in output (templates, images)
```

**Why this structure matters:** Skills use a three-level loading system to manage context efficiently:

1. **Metadata** (name + description from frontmatter) — always in context (~100 words)
2. **SKILL.md body** — loaded when the skill triggers (<5k words)
3. **Bundled resources** (references, scripts, assets) — loaded as needed by the agent

This mirrors the progressive disclosure pattern: agents start with a lightweight map and drill deeper only when needed, preserving context window for the actual task.

### Skill Resources

- **Scripts** (`scripts/`) — Code that would otherwise be rewritten every invocation. Token-efficient because scripts can be executed without being read into context. Example: `recon.sh` in codebase-readiness gathers project metadata deterministically.

- **References** (`references/`) — Domain knowledge loaded into context when the agent determines it's needed. Keeps SKILL.md lean while making deep knowledge discoverable. Example: codebase-readiness stores language-specific scoring rubrics (Ruby, Python, TypeScript, etc.) and dimension guides as separate reference files.

- **Assets** (`assets/`) — Files used in output, not loaded into context. Templates, images, boilerplate that get copied or modified. Example: report templates that agents fill in with assessment results.

### Supporting Content

- **`configs/`** — Opinionated Claude Code configuration recommendations (status bar, MCP servers)
- **`tips/`** — Short-form guides for Claude Code workflows (worktrees, subagents, context management)
- **`scripts/`** — Utility scripts not tied to a specific plugin

### CI Validation (`.github/workflows/`)

Enforces structural invariants mechanically:

- **Skill validation** — Checks SKILL.md frontmatter format, required fields, naming conventions on every PR
- **JSON validation** — Ensures all plugin.json and marketplace.json files are syntactically valid

These checks encode "taste" as enforceable rules — agents and contributors can ship fast without undermining structural consistency.

## Invariants

These rules are enforced either by CI or by convention:

1. **Every plugin has a plugin.json** with name, version, description
2. **Every skill has a SKILL.md** with valid frontmatter (name + description)
3. **Versions are synchronized** between plugin.json and marketplace.json
4. **Skill names are kebab-case**, max 64 characters
5. **No stale JSON** — all JSON files parse cleanly
6. **Skills are self-contained** — a plugin directory contains everything needed to use it

## Design Decisions

### Why plugins over a monolithic skill collection?

Plugins are independently installable and versionable. A user who only needs TDD workflow doesn't pull in meeting transcript processing. This also allows different release cadences per plugin.

### Why reference files instead of large SKILL.md files?

Context is a scarce resource. A 2,000-line SKILL.md crowds out the actual task. Reference files let agents load only what's relevant — a Ruby assessment doesn't need to read the Scala rubric. This follows the same principle described in OpenAI's [Harness Engineering](https://openai.com/index/harness-engineering/) post: "give the agent a map, not a 1,000-page instruction manual."

### Why enforce structure in CI?

Documentation alone doesn't keep a growing plugin ecosystem coherent. Mechanical enforcement catches drift before it compounds — the same principle behind custom linters in agent-first codebases. A broken frontmatter field means the skill won't trigger correctly; catching it in CI is cheaper than debugging it in production.
