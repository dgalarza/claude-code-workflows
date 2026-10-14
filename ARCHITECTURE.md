# Architecture

## Design Philosophy

This repository is the system of record for agent skills. Every skill lives in-repo as a versioned artifact that Claude Code, Cursor, Codex, and other agents can install.

The architecture follows progressive disclosure. An agent sees a small entry point (SKILL.md frontmatter), then the SKILL.md body, then references, scripts, and assets.

## Component Map

### Canonical skills (`skills/`)

```
skills/<name>/
├── SKILL.md          ← the skill
├── scripts/          ← deterministic, executable code
├── references/       ← documentation loaded into context as needed
└── assets/           ← files used in output (templates, images)
```

Plugin template tests stay next to the plugin (`plugins/<name>/tests/`) so they are not part of the installed skill tree.

**Why this structure matters:** Skills use a three-level loading system:

1. **Metadata** (name + description from frontmatter) — always in context (~100 words)
2. **SKILL.md body** — loaded when the skill triggers (<5k words)
3. **Bundled resources** (references, scripts, assets) — loaded as needed

A Ruby assessment does not need the Scala rubric in context. Reference files keep the body small.

### Plugin marketplace (`.claude-plugin/marketplace.json`)

The registry Claude Code reads for `/plugin marketplace add` and `/plugin install`. The marketplace `name` is `dgalarza-agent-skills`. That name is what users type after `@`. Claude Code reserves the bare name `agent-skills` for marketplaces from `github.com/anthropics/` and refuses to add it from any other source, so keep the `dgalarza-` prefix.

Three plugins:

| Plugin | Skills |
|--------|--------|
| `codebase-readiness` | assessment |
| `agent-ready` | scaffold, quality gates, migrate, audit |
| `engineering-skills` | team-code-review, stacked-prs, conventional-comments, conventional-commits, tdd |

`buffer`, `buttondown`, and `herdr-code-review` are skills with no plugin entry. `npx skills` discovers them from `skills/`.

The `renames` object records old plugin names. A string value is the plugin to load instead. `null` means the plugin was removed. Claude Code follows the chain and stops at a current plugin name or `null`. The map is append-only.

`forceRemoveDeletedPlugins` is unset, so a removal notice does not uninstall files from a user's machine.

### Thin plugins (`plugins/`)

A plugin directory holds a manifest, a README, and symlinks:

```
plugins/<name>/
├── .claude-plugin/plugin.json
├── README.md
└── skills/<skill-name> -> ../../../skills/<skill-name>
```

Component paths in a manifest have to stay inside the plugin root, so the manifest does not point at `../skills` with a relative path. A symlink whose target is elsewhere in this same marketplace is the supported way to share one skill across plugins. Claude Code dereferences that symlink and copies the target into the plugin cache. A symlink that leaves the marketplace is ignored.

### Skill resources

- **Scripts** (`scripts/`) — code that would otherwise be rewritten every run. `recon.sh` in codebase-readiness gathers project metadata without a model.
- **References** (`references/`) — domain knowledge loaded when the agent needs it.
- **Assets** (`assets/`) — templates copied into the user's project or report. They are not loaded as instructions.

### CI (`.github/workflows/`)

- **Skill validation** — SKILL.md frontmatter on changed skills under `skills/`.
- **Template tests** — the agent-ready quality-gate engine.
- **JSON validation** — `marketplace.json` and every `plugin.json`.

`.agents/skills/skill-creator` is vendored tooling for that validation. It is not part of the catalog.

`scripts/` holds repository utilities that are not skills. `setup-rails-worktree.sh` is still here. The worktree tip that linked to it was removed with `tips/`.

## Invariants

1. Every published Claude plugin has a `plugin.json` with name, version, and description.
2. Every skill has a `SKILL.md` with valid frontmatter (name + description).
3. Versions match across `plugin.json` and `marketplace.json`.
4. Skill names are kebab-case, max 64 characters.
5. JSON files parse.
6. The canonical skill directory is `skills/<name>/`. Plugin `skills/` entries are symlinks to it.
7. Parallel skill steps include a sequential fallback for agents that cannot spawn subagents.

## Design Decisions

### Why three plugins?

`codebase-readiness` and `agent-ready` each map to a landing page and an email sequence, so they stay separately installable. `engineering-skills` is one install for the review, stacking, commit, comment, and TDD workflow. Operator utilities stay out of that bundle so a Claude install does not pull in newsletter and social APIs.

### Why skills at the repository root?

`npx skills` discovers `skills/<name>/SKILL.md` for Cursor, Codex, and the other agents the CLI supports. Claude plugins reuse those directories through symlinks instead of a second copy.

### Why reference files instead of large SKILL.md files?

Context is scarce. Reference files let an agent load the Ruby rubric without the Scala rubric. The same idea is in OpenAI's [Harness Engineering](https://openai.com/index/harness-engineering/) post: give the agent a map, not a 1,000-page manual.

### Why CalVer on plugins and date tags on the repo?

Plugin and marketplace versions use `YYYY.MM.PATCH` (example `2026.10.0`) so a release is a date plus a counter inside that month. Git tags stay `YYYY.MM.DD`, which is the tag scheme this repository already publishes. The tag answers "what snapshot is this?" The plugin version answers "which revision of this plugin is installed?"

### Why `renames` instead of deleting names quietly?

Claude Code reports a missing plugin when an enabled name disappears. `renames` migrates `tdd-workflow` and `conventional-commits` to `engineering-skills`, and tells users when a retired plugin is gone.
