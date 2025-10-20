# Commitlint Setup Guide

This guide shows how to set up automated commit message validation using commitlint.

## Why Commitlint?

Commitlint helps teams:
- Enforce consistent commit message format
- Catch formatting errors before they reach the repository
- Enable automated tooling (changelogs, versioning)
- Improve collaboration through clear conventions

## Installation

### 1. Install Dependencies

```bash
npm install --save-dev @commitlint/{cli,config-conventional}
```

### 2. Create Configuration File

Create `.commitlintrc.json` in the project root:

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "perf",
        "test",
        "chore",
        "build",
        "ci",
        "revert"
      ]
    ],
    "scope-enum": [
      2,
      "always",
      [
        "auth",
        "api",
        "dhf",
        "traceability",
        "github",
        "linear",
        "jira",
        "ui",
        "models",
        "services",
        "jobs",
        "tests",
        "deps",
        "db",
        "tenants"
      ]
    ],
    "scope-empty": [1, "never"],
    "subject-case": [2, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
    "header-max-length": [2, "always", 72],
    "body-leading-blank": [1, "always"],
    "body-max-line-length": [2, "always", 100],
    "footer-leading-blank": [1, "always"]
  }
}
```

### 3. Set Up Git Hook (Recommended)

#### Option A: Using Husky

Install Husky:

```bash
npm install --save-dev husky
npx husky init
```

Create commit message hook:

```bash
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
chmod +x .husky/commit-msg
```

#### Option B: Manual Git Hook

Create `.git/hooks/commit-msg`:

```bash
#!/bin/bash
npx --no -- commitlint --edit $1
```

Make it executable:

```bash
chmod +x .git/hooks/commit-msg
```

## Configuration Details

### Rule Levels

- `0` - Disabled
- `1` - Warning
- `2` - Error (blocks commit)

### Key Rules Explained

**type-enum**
- Enforces allowed commit types
- Customized for Tracewell project needs

**scope-enum**
- Enforces allowed scopes
- Matches Tracewell domain areas

**scope-empty**
- Level 1 (warning) - encourages scopes but doesn't require
- Change to level 2 to require scopes

**subject-case**
- Enforces lowercase first letter
- Follows Conventional Commits spec

**header-max-length**
- Limits first line to 72 characters
- Keeps commit messages readable in git log

**body-max-line-length**
- Wraps body text at 100 characters
- Maintains readability

## Testing Commitlint

Test your configuration without making a commit:

```bash
echo "feat: add new feature" | npx commitlint
echo "Fix: something wrong" | npx commitlint  # Should fail
echo "feat(api): add endpoint" | npx commitlint
```

## CI Integration

### GitHub Actions

Create `.github/workflows/commitlint.yml`:

```yaml
name: Commitlint

on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install commitlint
        run: npm install --save-dev @commitlint/{cli,config-conventional}

      - name: Validate PR commits
        run: npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }} --verbose
```

### GitLab CI

Add to `.gitlab-ci.yml`:

```yaml
commitlint:
  stage: test
  image: node:20
  before_script:
    - npm install --save-dev @commitlint/{cli,config-conventional}
  script:
    - npx commitlint --from $CI_MERGE_REQUEST_DIFF_BASE_SHA --to HEAD --verbose
  only:
    - merge_requests
```

## Customization

### Project-Specific Scopes

Update the `scope-enum` rule to match your project structure:

```json
{
  "rules": {
    "scope-enum": [
      2,
      "always",
      [
        "your-scope-1",
        "your-scope-2",
        "your-scope-3"
      ]
    ]
  }
}
```

### Relaxed Configuration

For teams transitioning to Conventional Commits:

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "scope-empty": [0],  // Allow empty scopes
    "subject-case": [1, "always", "lower-case"],  // Warn instead of error
    "header-max-length": [1, "always", 100]  // More lenient length
  }
}
```

### Strict Configuration

For teams wanting maximum consistency:

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "scope-empty": [2, "never"],  // Require scopes
    "body-max-length": [2, "always", 72],  // Strict wrapping
    "footer-max-length": [2, "always", 72],
    "references-empty": [2, "never"]  // Require issue references
  }
}
```

## Common Issues

### Issue: Commitlint not running

**Solution 1**: Check hook is executable
```bash
ls -la .husky/commit-msg
chmod +x .husky/commit-msg
```

**Solution 2**: Verify hook file syntax
```bash
cat .husky/commit-msg
# Should contain: npx --no -- commitlint --edit $1
```

### Issue: "Cannot find module @commitlint/config-conventional"

**Solution**: Install dependencies
```bash
npm install
# or
npm install --save-dev @commitlint/{cli,config-conventional}
```

### Issue: Existing commits fail validation

**Solution**: Only validate new commits, not history
```bash
# In .husky/commit-msg, only validate the current commit
npx --no -- commitlint --edit $1
```

### Issue: Merge commits fail validation

**Solution**: Add rule to allow merge commits
```json
{
  "rules": {
    "header-max-length": [2, "always", 72],
    "type-enum": [2, "always", ["feat", "fix", "...", "merge"]]
  }
}
```

Or ignore merge commits entirely:

```json
{
  "ignores": [
    (message) => message.startsWith("Merge ")
  ]
}
```

## Package.json Scripts

Add helpful scripts to `package.json`:

```json
{
  "scripts": {
    "commitlint": "commitlint --edit",
    "commitlint:check": "commitlint --from HEAD~1 --to HEAD --verbose",
    "commitlint:ci": "commitlint --from $CI_BASE_SHA --to HEAD --verbose"
  }
}
```

## Integration with Other Tools

### With Conventional Changelog

```bash
npm install --save-dev conventional-changelog-cli

# Add to package.json
{
  "scripts": {
    "changelog": "conventional-changelog -p angular -i CHANGELOG.md -s"
  }
}
```

### With Standard Version

```bash
npm install --save-dev standard-version

# Add to package.json
{
  "scripts": {
    "release": "standard-version"
  }
}
```

### With Semantic Release

```bash
npm install --save-dev semantic-release

# Add to package.json
{
  "scripts": {
    "semantic-release": "semantic-release"
  }
}
```

## Best Practices

1. **Start with warnings**: Use level 1 rules initially, upgrade to level 2 after team adoption
2. **Document exceptions**: Use `.commitlintrc.json` comments to explain custom rules
3. **CI validation**: Always validate commits in CI, not just locally
4. **Team training**: Share commit examples and run workshops
5. **Gradual rollout**: Start with new projects before applying to existing ones

## Example Commit Messages

### Valid Examples

```
feat(api): add user authentication endpoint

fix(db): resolve migration rollback issue

docs: update README with installation steps

chore(deps): bump rails from 7.1.0 to 7.2.0
```

### Invalid Examples (Will be blocked)

```
Add feature          # ❌ Missing type
feat: Add Feature    # ❌ Capitalized subject
fix: resolve bug.    # ❌ Period at end
FEAT: new feature    # ❌ Uppercase type
```

## Disabling Commitlint

If you need to bypass commitlint for a specific commit:

```bash
git commit --no-verify -m "emergency fix"
```

⚠️ Use sparingly - defeats the purpose of validation!

## Resources

- [Commitlint Documentation](https://commitlint.js.org/)
- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Commitlint Rules Reference](https://commitlint.js.org/#/reference-rules)
- [Husky Documentation](https://typicode.github.io/husky/)

## Summary

Commitlint provides:
- ✅ Automated commit message validation
- ✅ Consistent commit history
- ✅ Better team collaboration
- ✅ Foundation for automated tooling
- ✅ CI/CD integration

Start with a relaxed configuration and gradually increase strictness as your team adopts the conventions.
