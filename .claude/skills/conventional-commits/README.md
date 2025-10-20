# Conventional Commits Skill

A Claude Code skill for writing Git commits that follow the [Conventional Commits specification](https://www.conventionalcommits.org/).

## Quick Start

This skill helps you write clear, structured commit messages that enable:
- Automatic changelog generation
- Semantic versioning
- Better collaboration and code review
- Clear project history

## Basic Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Common Types

- `feat` - New feature for users
- `fix` - Bug fix
- `docs` - Documentation changes
- `refactor` - Code refactoring
- `test` - Test additions or updates
- `chore` - Maintenance tasks, dependency updates

## Quick Examples

```bash
feat: add user authentication
fix(api): handle null response from webhook
docs: update README with setup instructions
refactor(database): optimize user query performance
chore(deps): bump Rails to 7.2.0
```

## Usage in Claude Code

This skill is automatically invoked when you ask Claude to create Git commits. Claude will:
- Analyze the changes
- Select the appropriate commit type
- Write a clear, concise description
- Add context in the body when needed
- Reference relevant issues in footers

## Documentation

- **[SKILL.md](./SKILL.md)** - Complete guide with all commit types, formatting rules, and best practices
- **[references/commit-examples.md](./references/commit-examples.md)** - Real-world commit examples
- **[references/commitlint-setup.md](./references/commitlint-setup.md)** - Automated validation setup

## Breaking Changes

For commits with breaking changes, use either:

```bash
feat!: change authentication endpoint
```

Or add a footer:

```bash
feat(api): change authentication endpoint

BREAKING CHANGE: The /auth endpoint now requires a client_id parameter.
```

## Best Practices

✅ Use imperative mood: "add" not "added"
✅ Keep description under 50 characters
✅ Don't capitalize first letter
✅ No period at the end
✅ Make atomic commits (one logical change)

❌ Avoid vague descriptions like "fix stuff"
❌ Don't combine unrelated changes
❌ Don't commit broken code

## References

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Commitlint Documentation](https://commitlint.js.org/)
