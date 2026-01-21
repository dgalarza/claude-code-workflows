# Conventional Commits

Structured commit messages following the [Conventional Commits](https://www.conventionalcommits.org/) specification.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "conventional-commits"

# Or via Claude marketplace
/plugin install conventional-commits@dgalarza-workflows
```

## What It Does

Guides Claude to create consistent, meaningful commit messages that are both human and machine-readable.

## Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat` | New feature | `feat(api): add webhook signature verification` |
| `fix` | Bug fix | `fix: resolve login redirect loop` |
| `docs` | Documentation | `docs: update README with setup instructions` |
| `style` | Formatting | `style: format code with StandardRB` |
| `refactor` | Code restructuring | `refactor: extract validation to service object` |
| `perf` | Performance | `perf: add database index for user lookups` |
| `test` | Tests | `test: add specs for user authentication` |
| `chore` | Maintenance | `chore: update Rails to 7.2.0` |
| `ci` | CI changes | `ci: add security scanning to GitHub Actions` |
| `build` | Build system | `build: configure Docker for production` |

## Scopes

Optional context about what changed:

```
feat(auth): add two-factor authentication
fix(api): handle rate limit errors
refactor(services): extract common validation logic
```

Common scopes: `auth`, `api`, `ui`, `db`, `services`, `jobs`, `tests`, `deps`, `config`

## Rules

- Use imperative mood: "add" not "added"
- Don't capitalize first letter
- No period at end
- Keep under 72 characters (ideally under 50)

## Breaking Changes

Mark with `!` or `BREAKING CHANGE:` footer:

```
feat(api)!: change authentication endpoint

BREAKING CHANGE: The /auth endpoint now requires a client_id parameter.
```

## Issue References

```
fix(auth): resolve session timeout bug

Fixes #123
Related to #456
```

## When It Activates

Automatically when creating Git commits.

## Reference Material

The skill includes comprehensive reference material with:
- Complete type definitions
- Scope examples
- Body and footer formatting
- Real-world examples
