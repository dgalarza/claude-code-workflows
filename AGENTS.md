# Agent Skills

Contributor guide for this skills library. Codex, Cursor, and other agents that read `AGENTS.md` should follow this file. The marketplace name is `dgalarza-agent-skills`. The GitHub repository is `dgalarza/claude-code-workflows` until that repository is renamed to `dgalarza/agent-skills`.

Architecture and the reasons for the layout are in [ARCHITECTURE.md](ARCHITECTURE.md).

## Repository Structure

```
skills/<name>/
  SKILL.md                    # Canonical skill (required)
  scripts/                    # Executable code (optional)
  references/                 # Docs loaded into context as needed (optional)
  assets/                     # Templates and files used in output (optional)
plugins/<plugin-name>/
  .claude-plugin/plugin.json  # Thin manifest: name, version, description, author
  README.md                   # User-facing plugin docs
  skills/<name>               # Symlink to ../../../skills/<name>
  tests/                      # Tests of that plugin's templates, when present
.claude-plugin/marketplace.json
.agents/skills/               # Vendored skill-creator used by CI. Not a published skill
```

Claude Code plugins are `codebase-readiness`, `agent-ready`, and `engineering-skills`. Operator utilities (`buffer`, `buttondown`, `herdr-code-review`) stay under `skills/` and are installed with `npx skills` only.

Symlinks stay inside this repository. Claude Code dereferences a symlink whose target is another directory in the same marketplace and copies that content into the plugin cache.

## Key Conventions

- Plugin versions live in `plugins/<name>/.claude-plugin/plugin.json` and in `.claude-plugin/marketplace.json` (the plugin entry and the marketplace `version`). Keep them in sync.
- Versions use calendar versioning: `YYYY.MM.PATCH` (this consolidation is `2026.10.0`). Increment `PATCH` for later changes in the same month.
- SKILL.md frontmatter requires `name` (kebab-case, max 64 characters) and `description` (max 1024 characters, no angle brackets).
- Skill instructions use imperative or infinitive form.
- Skill steps that can run in parallel must also say what to do when the runtime has no subagents.
- JSON files must be valid. CI checks this.
- Commit messages follow conventional commits: `feat:`, `fix:`, `chore:`, `docs:`.

## Development Workflow

1. Add or edit the skill under `skills/<name>/`.
2. For a Claude plugin, point `plugins/<plugin>/skills/<name>` at `../../../skills/<name>` and list the plugin in `.claude-plugin/marketplace.json`.
3. Validate locally: `python3 .agents/skills/skill-creator/scripts/quick_validate.py skills/<name>`
4. CI validates skills and JSON on pull requests.
5. Bump the CalVer version in both plugin.json and marketplace.json before merging behavior changes.

## Releasing

Git tags for the marketplace snapshot stay `YYYY.MM.DD`. If more than one tag lands on the same day, append a suffix: `YYYY.MM.DD.2`. Plugin and marketplace versions stay `YYYY.MM.PATCH`.

### When to Release

Cut a release when one or more of these land on `main`:

- New plugin or skill added
- New feature or language support added to an existing skill
- Bug fix that affects skill or plugin behavior

Documentation-only changes do not need a release.

### Release Checklist

1. Bump the plugin version in `plugins/<name>/.claude-plugin/plugin.json` using `YYYY.MM.PATCH`.
2. Set the same version on that plugin's entry and on the top-level `version` in `.claude-plugin/marketplace.json`.
3. Commit the version bump with the change, or as `chore: bump <plugin> to YYYY.MM.PATCH`.
4. After the merge to `main`:

   ```bash
   git tag YYYY.MM.DD
   git push origin YYYY.MM.DD
   ```

5. Create a GitHub release from the tag with a short summary.

Retired plugin names stay in the marketplace `renames` map. Map a removed plugin to `null`. Map a plugin that moved into another plugin to that plugin's name. Keep old `renames` entries when adding new ones.

## Adding a Skill

1. Create `skills/<name>/SKILL.md` with frontmatter and instructions.
2. To ship it in Claude Code, add a symlink under the right plugin and a marketplace entry.
3. Add a short row to the matching group in `README.md` and `INSTALL.md`.
4. Leave operator utilities out of `.claude-plugin/marketplace.json`.
