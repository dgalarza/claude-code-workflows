# Recommended Project Skills

Use this catalog to recommend a small, opinionated set of project-local skills when strong framework signals are present. Recommend only listed skills; do not improvise additional recommendations from weak signals.

## Detection

Inspect dependency sections in the root and workspace `package.json` files. Check tracked source/config files only when noted below. Ignore `node_modules/` and do not infer a framework from a lockfile entry alone because transitive dependencies create false positives.

Before recommending anything, run `npx skills list --json` from the repository root when available. Exclude skills already installed in project scope. If the command is unavailable, check common project-local locations such as `.agents/skills/`, `.claude/skills/`, and `skills-lock.json`.

## Catalog

### React

**Strong signal:** A root or workspace `package.json` declares `react` in `dependencies`, `devDependencies`, `peerDependencies`, or `optionalDependencies`.

**Recommend:** `vercel-react-best-practices` from [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills). It supplies Vercel Engineering's React and Next.js performance guidance for component authoring, data fetching, rendering, and bundle optimization.

**Project-local install:**

```bash
npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices --yes
```

### Mastra

**Strong signal:** A root or workspace `package.json` declares `mastra` or a package beginning with `@mastra/`, or the repository contains the conventional `src/mastra/index.ts` or `src/mastra/index.js` entry point.

**Recommend:** `mastra` from [mastra-ai/skills](https://github.com/mastra-ai/skills). This is Mastra's official skill for current APIs, embedded documentation lookup, setup, migrations, and troubleshooting.

**Project-local install:**

```bash
npx skills add mastra-ai/skills --skill mastra --yes
```

## Installation Policy

- Present all missing matches together and ask once whether to install all, a selected subset, or none.
- Explain that installation is project-local and may update skill directories and `skills-lock.json`.
- Wait for explicit confirmation before running any install command.
- After confirmation, use the exact catalog command. `--yes` suppresses a redundant CLI prompt; omitting `--global` keeps the install in project scope.
- Run one command per selected skill so failures are attributable and do not block other selections.
- If `npx` is unavailable or installation fails, report the error, show the manual command, and continue the requested agent-ready mode.
