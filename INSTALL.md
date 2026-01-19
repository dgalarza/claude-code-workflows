# Installation

## Quick Start

Add this marketplace to Claude Code, then install any plugin you want.

### Step 1: Add the Marketplace

```bash
/plugin marketplace add dgalarza/claude-code-workflows
```

### Step 2: Install Plugins

Install individual plugins:

```bash
/plugin install tdd-workflow@dgalarza-workflows
/plugin install conventional-commits@dgalarza-workflows
/plugin install cybersecurity-reviewer@dgalarza-workflows
```

Or install the Rails bundle (includes multiple agents, commands, and skills):

```bash
/plugin install rails-toolkit@dgalarza-workflows
```

### Step 3: Use Them

Skills are automatically activated when relevant. Commands use the plugin namespace:

```bash
# Rails toolkit commands
/rails-toolkit:full-code-review
/rails-toolkit:linear-worktree tracewell2 TRA-9
```

## Available Plugins

| Plugin | Type | Description |
|--------|------|-------------|
| `tdd-workflow` | Skill | Red-green-refactor TDD workflow |
| `conventional-commits` | Skill | Structured commit messages |
| `parallel-code-review` | Skill | Multi-agent code reviews |
| `meeting-transcript` | Skill | Process transcripts into notes |
| `cybersecurity-reviewer` | Agent | Security vulnerability analysis |
| `gridfinity-planner` | Agent | 3D printing baseplate planning |
| `rails-toolkit` | Bundle | Complete Rails dev workflow |

## Manual Installation

If you prefer to copy files manually:

1. Clone this repo
2. Copy the desired plugin folder contents into your project's `.claude/` directory

```bash
# Example: Install tdd-workflow manually
cp -r plugins/tdd-workflow/skills/tdd-workflow ~/.claude/skills/
```

## Updating Plugins

To update to the latest version:

```bash
/plugin update tdd-workflow@dgalarza-workflows
```

Or update all plugins from this marketplace:

```bash
/plugin update --marketplace dgalarza-workflows
```

## Uninstalling

```bash
/plugin uninstall tdd-workflow@dgalarza-workflows
```
