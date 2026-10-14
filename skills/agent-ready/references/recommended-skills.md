# Recommended Project Skills

Use this catalog to recommend a small, opinionated set of project-local skills when strong stack signals are present. Recommend only listed skills; do not improvise recommendations from weak signals.

## Detection

Evaluate each package or workspace independently so a monorepo can match multiple entries without confusing one package's stack for another's.

Inspect direct dependencies in tracked manifests such as `package.json`, `pyproject.toml`, `requirements*.txt`, `Pipfile`, `composer.json`, `Gemfile`, and `go.mod`. Check tracked source or configuration files only when noted below. Ignore dependency lockfiles, `node_modules/`, `vendor/`, generated files, and transitive dependencies because they create false positives.

Before recommending anything, run `npx skills list --json` from the repository root when available. Exclude skills already installed in project scope. If the command is unavailable, check common project-local locations such as `.agents/skills/`, `.claude/skills/`, and `skills-lock.json`.

## Core Catalog

### React Web

**Strong signal:** A package declares `react` directly and does not declare `react-native` or `expo` in that same package. In a mixed monorepo, match web and native workspaces separately.

**Recommend:** `vercel-react-best-practices` from [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) for React and Next.js performance, data fetching, rendering, and bundle optimization.

```bash
npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices --yes
```

### React Native or Expo

**Strong signal:** A package declares `react-native` or `expo` directly.

**Recommend:** `vercel-react-native-skills` from [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) for performant React Native and Expo components, lists, animations, and native integrations.

```bash
npx skills add vercel-labs/agent-skills --skill vercel-react-native-skills --yes
```

### Angular

**Strong signal:** A package declares `@angular/core` directly.

**Recommend:** `angular-developer` from the official [angular/angular](https://github.com/angular/angular) repository for current Angular architecture, signals, forms, routing, accessibility, and testing.

```bash
npx skills add angular/angular --skill angular-developer --yes
```

### Svelte

**Strong signal:** A package declares `svelte` directly.

**Recommend:** `svelte-core-bestpractices` from the official [sveltejs/ai-tools](https://github.com/sveltejs/ai-tools) repository for modern Svelte reactivity, event handling, styling, and integrations.

```bash
npx skills add sveltejs/ai-tools --skill svelte-core-bestpractices --yes
```

### Mastra

**Strong signal:** A package declares `mastra` or a package beginning with `@mastra/`, or the repository contains the conventional `src/mastra/index.ts` or `src/mastra/index.js` entry point.

**Recommend:** `mastra` from [mastra-ai/skills](https://github.com/mastra-ai/skills), Mastra's official skill for current APIs, embedded documentation lookup, setup, migrations, and troubleshooting.

```bash
npx skills add mastra-ai/skills --skill mastra --yes
```

### FastAPI

**Strong signal:** A Python dependency manifest declares `fastapi` directly, or tracked application code imports `fastapi` and no dependency manifest is present.

**Recommend:** `fastapi` from the official [fastapi/fastapi](https://github.com/fastapi/fastapi) repository for current API, Pydantic, dependency injection, streaming, and application conventions.

```bash
npx skills add fastapi/fastapi --skill fastapi --yes
```

### Laravel

**Strong signal:** `composer.json` declares `laravel/framework`, or both `artisan` and `bootstrap/app.php` exist.

**Recommend:** `laravel-best-practices` from the official [laravel/boost](https://github.com/laravel/boost) repository for controllers, models, migrations, authorization, queues, testing, and Eloquent performance.

```bash
npx skills add laravel/boost --skill laravel-best-practices --yes
```

### Supabase

**Strong signal:** A package declares `@supabase/supabase-js`, `@supabase/ssr`, or another direct `@supabase/` dependency; a Python manifest declares `supabase`; or `supabase/config.toml` exists.

**Recommend:** `supabase` from the official [supabase/agent-skills](https://github.com/supabase/agent-skills) repository for Database, Auth, Edge Functions, Realtime, Storage, migrations, RLS, and troubleshooting.

```bash
npx skills add supabase/agent-skills --skill supabase --yes
```

### Stripe

**Strong signal:** A direct dependency uses an official Stripe SDK, including `stripe`, an `@stripe/` package, `stripe/stripe-php`, the Ruby `stripe` gem, or `github.com/stripe/stripe-go`.

**Recommend:** `stripe-best-practices` from the official [stripe/ai](https://github.com/stripe/ai) repository for payments, subscriptions, Connect, tax, API choices, webhooks, and key security.

```bash
npx skills add stripe/ai --skill stripe-best-practices --yes
```

### Cloudflare Workers

**Strong signal:** `wrangler.toml`, `wrangler.json`, or `wrangler.jsonc` exists, or a package directly declares `wrangler` or `@cloudflare/workers-types` and contains Worker source code.

**Recommend:** `workers-best-practices` from the official [cloudflare/skills](https://github.com/cloudflare/skills) repository for production Worker code, bindings, streaming, promises, secrets, and observability.

```bash
npx skills add cloudflare/skills --skill workers-best-practices --yes
```

### Terraform

**Strong signal:** The tracked repository contains authored `.tf`, `.tf.json`, `.tfstack.hcl`, or `.tfcomponent.hcl` files outside generated, fixture, vendored, and `.terraform/` directories.

**Recommend:** `terraform-style-guide` from the official [hashicorp/agent-skills](https://github.com/hashicorp/agent-skills) repository for HashiCorp's Terraform HCL conventions and module style.

```bash
npx skills add hashicorp/agent-skills --skill terraform-style-guide --yes
```

## Optional UI Catalog

Treat these as optional rather than part of the default core set. Match only when repository structure and source files show a user-facing browser UI, such as application routes/pages plus rendered components and styles. Do not match a package solely because it depends on React or another UI framework; skip backend services, CLIs, headless packages, and non-visual libraries.

### Frontend Design

**Recommend:** `frontend-design` from [anthropics/skills](https://github.com/anthropics/skills) for intentional visual direction, typography, and non-generic interface design.

```bash
npx skills add anthropics/skills --skill frontend-design --yes
```

### Web Design Guidelines

**Recommend:** `web-design-guidelines` from [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) for accessibility, interaction, responsive design, performance, and UX review guidance.

```bash
npx skills add vercel-labs/agent-skills --skill web-design-guidelines --yes
```

## Installation Policy

- Present all missing core matches under **Recommended** and UI matches under **Optional**.
- Ask once whether to install recommended skills only, recommended plus optional skills, a selected subset, or none. Do not include optional skills in the default choice.
- Explain that installation is project-local and may update skill directories and `skills-lock.json`.
- Wait for explicit confirmation before running any install command.
- After confirmation, use the exact catalog command. `--yes` suppresses a redundant CLI prompt; omitting `--global` keeps the install in project scope.
- Run one command per selected skill so failures are attributable and do not block other selections.
- If `npx` is unavailable or installation fails, report the error, show the manual command, and continue the requested agent-ready mode.
