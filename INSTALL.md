# Installation

Canonical install paths for this library. Marketplace name: `dgalarza-agent-skills`. Repository shorthand: `dgalarza/agent-skills`.

The GitHub rename from `dgalarza/claude-code-workflows` to `dgalarza/agent-skills` happens after this change merges. Use the commands below once that rename is in place. Rename the existing repository so the old URL keeps redirecting. A new repository created with the old name would break that redirect.

## Claude Code

```bash
/plugin marketplace add dgalarza/agent-skills
/plugin install <name>@dgalarza-agent-skills
```

Plugins:

| Plugin | Install name | What it contains |
|--------|----------------|------------------|
| Codebase Readiness | `codebase-readiness` | 8-dimension assessment. Get it from [the landing page](https://www.damiangalarza.com/codebase-readiness/). |
| Agent Ready | `agent-ready` | Documentation scaffold, quality gates, migrate, and audit. Get it from [the landing page](https://www.damiangalarza.com/agent-ready/). |
| Engineering skills | `engineering-skills` | `team-code-review`, `stacked-prs`, `conventional-comments`, `conventional-commits`, `tdd` |

```bash
/plugin install engineering-skills@dgalarza-agent-skills
```

Operator utilities are not Claude plugins. Install them with `npx skills`.

## Cursor, Codex, and other agents

```bash
npx skills add dgalarza/agent-skills [-a cursor|codex]
```

Examples:

```bash
npx skills add dgalarza/agent-skills --skill team-code-review -a cursor
npx skills add dgalarza/agent-skills --skill stacked-prs -a codex
npx skills add dgalarza/agent-skills --skill buffer
npx skills add dgalarza/agent-skills --skill buttondown
npx skills add dgalarza/agent-skills --skill herdr-code-review
```

`-a cursor` installs into Cursor's skill directory. `-a codex` installs into Codex's skill directory. Omit `-a` to use the CLI default for the current agent.

## Skills

Canonical files are `skills/<name>/SKILL.md`. Plugins symlink at those directories.

### Engineering (`engineering-skills`)

| Skill | Description |
|-------|-------------|
| `team-code-review` | Specialist review with every finding verified before it is reported |
| `stacked-prs` | Dependent pull requests via GitHub stacked PRs and `gh stack` |
| `conventional-comments` | Structured review comments |
| `conventional-commits` | Structured commit messages |
| `tdd` | Red-green-refactor, one behavior at a time. No install hook |

### Productivity (npx only)

| Skill | Description |
|-------|-------------|
| `buffer` | Buffer scheduling API. Requires `BUFFER_API_TOKEN` |
| `buttondown` | Buttondown newsletter API. Requires `BUTTONDOWN_API_KEY` |
| `herdr-code-review` | Delegate `team-code-review` to a fresh sibling Herdr pane. Requires `HERDR_ENV=1` and the `team-code-review` skill |

### Assess and prepare

`codebase-readiness` and `agent-ready` are separate plugins so each can stay attached to its landing page. The pages above are the supported entry points.

## Updating and uninstalling

```bash
/plugin update engineering-skills@dgalarza-agent-skills
/plugin uninstall engineering-skills@dgalarza-agent-skills
```

Marketplace renames map `tdd-workflow` and `conventional-commits` to `engineering-skills`. Retired plugins map to removal. See the changelog for the full list.
