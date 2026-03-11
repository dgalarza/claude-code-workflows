# Claude Code Workflows

A plugin marketplace for Claude Code — skills, agents, and bundles that extend Claude's capabilities with specialized workflows.

For architecture details, design decisions, and the reasoning behind the plugin structure, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Repository Structure

```
plugins/                        # Each subdirectory is a standalone plugin
  <plugin-name>/
    .claude-plugin/plugin.json  # Name, version, description, author
    README.md                   # User-facing documentation
    skills/<skill-name>/
      SKILL.md                  # Frontmatter + instructions (required)
      scripts/                  # Executable code (optional)
      references/               # Docs loaded into context as needed (optional)
      assets/                   # Templates, files used in output (optional)
.claude-plugin/marketplace.json # Registry of all available plugins
.agents/skills/                 # Locally installed skills (e.g., skill-creator)
configs/                        # Claude Code configuration guides
tips/                           # Short-form workflow guides
scripts/                        # Utility scripts
```

## Key Conventions

- Plugin versions live in two places — bump both `plugins/<name>/.claude-plugin/plugin.json` AND `.claude-plugin/marketplace.json`
- SKILL.md frontmatter requires `name` (kebab-case, max 64 chars) and `description` (max 1024 chars, no angle brackets)
- Skill instructions use imperative/infinitive form, not second person
- All JSON files must be valid — CI checks this automatically
- Commit messages follow conventional commits: `feat:`, `fix:`, `chore:`, `docs:`

## Development Workflow

1. Create or modify plugins under `plugins/`
2. Validate locally: `python3 .agents/skills/skill-creator/scripts/quick_validate.py plugins/<name>/skills/<skill-name>`
3. CI validates skills and JSON on PRs automatically
4. Bump version in both plugin.json and marketplace.json before merging

## Adding a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with name, version, description, author
2. Create `plugins/<name>/skills/<skill-name>/SKILL.md` with frontmatter and instructions
3. Add the plugin entry to `.claude-plugin/marketplace.json`
4. Add a `plugins/<name>/README.md` for users
