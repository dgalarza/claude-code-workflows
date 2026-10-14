# engineering-skills

One Claude Code plugin for the day-to-day engineering workflow:

| Skill | What it does |
|-------|----------------|
| [team-code-review](../../skills/team-code-review/SKILL.md) | Dispatch specialist reviewers and verify every finding before reporting it |
| [stacked-prs](../../skills/stacked-prs/SKILL.md) | Split a large change into a chain of dependent pull requests with `gh stack` |
| [conventional-comments](../../skills/conventional-comments/SKILL.md) | Write review feedback in the [Conventional Comments](https://conventionalcomments.org/) format |
| [conventional-commits](../../skills/conventional-commits/SKILL.md) | Write commits that follow [Conventional Commits](https://www.conventionalcommits.org/) |
| [tdd](../../skills/tdd/SKILL.md) | Red-green-refactor, one behavior at a time, using the project's own test command |

`tdd` replaces the old `tdd-workflow` plugin. It has no prompt hook. `team-code-review` replaces parallel code review: the coordinating agent verifies each finding, and security review is one of the specialist lenses.

Skills are canonical under `skills/`. The `skills/` directory in this plugin is a set of symlinks. Claude Code dereferences symlinks inside the marketplace and copies the skill content into the plugin cache.

## Install

Claude Code:

```bash
/plugin marketplace add dgalarza/agent-skills
/plugin install engineering-skills@agent-skills
```

Cursor, Codex, and other agents — one skill:

```bash
npx skills add dgalarza/agent-skills --skill team-code-review
npx skills add dgalarza/agent-skills --skill tdd -a cursor
npx skills add dgalarza/agent-skills --skill stacked-prs -a codex
```

Operator utilities (buffer, buttondown, herdr-code-review) are not part of this plugin. Install those with `npx skills` only. See [INSTALL.md](../../INSTALL.md).
