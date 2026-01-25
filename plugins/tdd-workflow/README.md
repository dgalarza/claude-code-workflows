# TDD Workflow

Test-driven development skill that enforces the red-green-refactor cycle, one test at a time.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "tdd-workflow"

# Or via Claude marketplace
/plugin install tdd-workflow@dgalarza-workflows
```

## What It Does

This skill enforces true test-driven development by guiding Claude through the proper TDD cycle:

1. **Red**: Write ONE failing test for a single piece of functionality
2. **Green**: Write the minimal code needed to make the test pass
3. **Refactor**: Clean up the code while keeping tests green
4. **Repeat**: Move to the next piece of functionality

## Why This Matters

Without this skill, Claude tends to write entire test files upfront or implement multiple features at once. This skill enforces discipline:

- **One test at a time** - No writing full test suites before any implementation
- **Minimal code** - Only write what's needed to pass the current test
- **Continuous validation** - Run tests after each step to verify behavior

## When It Activates

The skill activates automatically when implementing features with TDD. You can also explicitly invoke it when you want Claude to follow strict TDD practices.

## Example Workflow

```
User: Implement a User model with email validation

Claude (with TDD skill):
1. Writes test: "it { should validate_presence_of(:email) }"
2. Runs test → Red (fails)
3. Adds validation to model
4. Runs test → Green (passes)
5. Refactors if needed
6. Writes next test: "it { should allow_value('user@example.com').for(:email) }"
7. Continues cycle...
```

## Anti-Patterns This Prevents

- Writing all tests before any implementation
- Implementing multiple features in one go
- Skipping the refactor step
- Not running tests between steps

## Auto-Activation Hook

This plugin includes a `UserPromptSubmit` hook that helps Claude find the TDD skill when your prompt mentions testing-related terms. While Claude can discover skills through their descriptions, this hook acts as a backup to ensure the skill activates reliably. The hook is automatically loaded when the plugin is installed - no manual configuration needed.

**Note**: Plugin hooks don't appear in the `/hooks` UI, but you can verify they're working by running `claude --debug` and looking for "Registered X hooks from X plugins" in the output.

### What It Detects

The hook looks for these patterns in your prompts:
- `tdd` (as a word)
- `test-driven` or `test driven`
- `test-first` or `test first`
- `red-green-refactor`
- `write a test` or `add a test`
- `testing`
- `unit test`
- `spec`

When matched, it injects "Use tdd-workflow" into the conversation context.

## Works Well With

- [Rails Toolkit](../rails-toolkit/README.md) - Uses TDD workflow for feature implementation
- [Parallel Code Review](../parallel-code-review/README.md) - Review code after TDD implementation
