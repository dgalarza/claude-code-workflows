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

## Releasing

This repo uses **calendar-based release tags** (`YYYY.MM.DD`) for the marketplace as a whole, and **semantic versioning** for individual plugins.

### When to Release

Cut a release when one or more of these land on `main`:
- New plugin added
- New feature or language support added to an existing plugin
- Bug fix that affects plugin behavior

Documentation-only changes (README updates, tips, configs) don't need a release.

### Release Checklist

1. **Bump plugin version** in `plugins/<name>/.claude-plugin/plugin.json` — follow semver (patch for fixes, minor for features, major for breaking changes)
2. **Sync version** in `.claude-plugin/marketplace.json` — must match the plugin.json version
3. **Commit** the version bumps with the feature/fix commit (or as a separate `chore: bump <plugin> to X.Y.Z` commit)
4. **Tag the release** after merging to `main`:
   ```bash
   git tag YYYY.MM.DD
   git push origin YYYY.MM.DD
   ```
5. **Create a GitHub release** from the tag with a brief summary of what changed

### Versioning Rules

- **Release tags** are calendar dates (`YYYY.MM.DD`). If multiple releases happen on the same day, append a suffix: `YYYY.MM.DD.2`
- **Plugin versions** are semver (`X.Y.Z`). The plugin version reflects changes to that specific plugin, not the overall repo
- Version must be bumped in **both** plugin.json and marketplace.json before merging — CI doesn't enforce sync yet, so this is a manual check

## Adding a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with name, version, description, author
2. Create `plugins/<name>/skills/<skill-name>/SKILL.md` with frontmatter and instructions
3. Add the plugin entry to `.claude-plugin/marketplace.json`
4. Add a `plugins/<name>/README.md` for users
