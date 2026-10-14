# Agent Skills

One skills library for Claude Code, Cursor, Codex, and other coding agents.

> **[YouTube](https://youtube.com/@damian.galarza)** | **[Newsletter](https://www.damiangalarza.com/newsletter?utm_source=github&utm_medium=readme&utm_campaign=agent-skills)** | **[Blog](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=agent-skills)**

Skills live in `skills/<name>/SKILL.md`. Claude Code plugins are thin manifests that point at those skills. Install details are in [INSTALL.md](INSTALL.md).

The GitHub repository is still `dgalarza/claude-code-workflows` until it is renamed to `dgalarza/agent-skills`. This tree is the library that rename should point at. Do not create a second repository with the old name.

---

## Assess & prepare

These two are the place to start. Each has its own landing page.

| Skill | What it does | Start here |
|-------|----------------|------------|
| Codebase Readiness | Score a repository across 8 dimensions (0-100) and get a band plus an improvement roadmap | [damiangalarza.com/codebase-readiness](https://www.damiangalarza.com/codebase-readiness/?utm_source=github&utm_medium=readme&utm_campaign=codebase-readiness) |
| Agent Ready | Scaffold AGENTS.md, ARCHITECTURE.md, docs, and a regression-aware quality gate. Claude Code 2.1.277+ reads AGENTS.md directly | [damiangalarza.com/agent-ready](https://www.damiangalarza.com/agent-ready/?utm_source=github&utm_medium=readme&utm_campaign=agent-ready) |

Source: [codebase-readiness](plugins/codebase-readiness/README.md) and [agent-ready](plugins/agent-ready/README.md).

After a score, a [Foundation Sprint](https://www.damiangalarza.com/services/?utm_source=github&utm_medium=readme&utm_campaign=agent-skills) is two weeks on the highest-leverage problem, with a Production AI retainer if the work should continue.

---

## Engineering

Install the bundle in Claude Code:

```bash
/plugin marketplace add dgalarza/agent-skills
/plugin install engineering-skills@agent-skills
```

Or one skill on Cursor, Codex, or another agent:

```bash
npx skills add dgalarza/agent-skills --skill team-code-review -a cursor
npx skills add dgalarza/agent-skills --skill tdd -a codex
```

| Skill | What it does |
|-------|----------------|
| [team-code-review](skills/team-code-review/SKILL.md) | Specialist review. Verify every finding before reporting it. Replaces parallel code review |
| [stacked-prs](skills/stacked-prs/SKILL.md) | Break a large change into dependent pull requests with `gh stack` |
| [conventional-comments](skills/conventional-comments/SKILL.md) | Review comments in the Conventional Comments format |
| [conventional-commits](skills/conventional-commits/SKILL.md) | Commit messages in the Conventional Commits format |
| [tdd](skills/tdd/SKILL.md) | Red-green-refactor, one behavior at a time, with the project's own test command |

The bundle manifest is [plugins/engineering-skills](plugins/engineering-skills/README.md).

---

## Productivity

These are operator utilities. They are not Claude plugins. Install with `npx skills`.

```bash
npx skills add dgalarza/agent-skills --skill buffer
npx skills add dgalarza/agent-skills --skill buttondown
npx skills add dgalarza/agent-skills --skill herdr-code-review
```

| Skill | What it does |
|-------|----------------|
| [buffer](skills/buffer/SKILL.md) | Schedule posts and manage a Buffer queue. Requires `BUFFER_API_TOKEN` |
| [buttondown](skills/buttondown/SKILL.md) | Manage Buttondown tags, automations, subscribers, and emails. Requires `BUTTONDOWN_API_KEY` |
| [herdr-code-review](skills/herdr-code-review/SKILL.md) | Run `team-code-review` in a fresh sibling Herdr pane. Requires `HERDR_ENV=1` |

---

If this helped, a star helps other people find it.

## Contributing

Bugs and workflow fixes are welcome. See [AGENTS.md](AGENTS.md) for the layout and how versions are bumped.

## License

[MIT](LICENSE)

---

**Built by [Damian Galarza](https://www.damiangalarza.com?utm_source=github&utm_medium=readme&utm_campaign=agent-skills)** — former CTO, production AI for engineering teams.
