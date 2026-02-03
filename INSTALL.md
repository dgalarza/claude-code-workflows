# Installation

## Installation Methods

There are two ways to install from this repository:

### npx skills (Skills only)

```bash
npx skills add dgalarza/claude-code-workflows --skill "tdd-workflow"
```

### Claude Marketplace (Skills, Agents, Bundles)

```bash
# Add the marketplace (one time)
/plugin marketplace add dgalarza/claude-code-workflows

# Install plugins
/plugin install tdd-workflow@dgalarza-workflows
```

---

## Available Plugins

### Skills

*Installable via npx or marketplace*

| Skill | Description |
|-------|-------------|
| `tdd-workflow` | Red-green-refactor TDD workflow |
| `conventional-commits` | Structured commit messages |
| `parallel-code-review` | Multi-agent code reviews |
| `meeting-transcript` | Process transcripts into notes |

```bash
# Via npx
npx skills add dgalarza/claude-code-workflows --skill "tdd-workflow"

# Via marketplace
/plugin install tdd-workflow@dgalarza-workflows
```

### Agents

*Marketplace only*

| Agent | Description |
|-------|-------------|
| `cybersecurity-reviewer` | Security vulnerability analysis |
| `gridfinity-planner` | 3D printing baseplate planning |

```bash
/plugin install cybersecurity-reviewer@dgalarza-workflows
```

### Bundles

*Marketplace only*

| Bundle | Description |
|--------|-------------|
| `rails-toolkit` | Complete Rails dev workflow (agents + commands + skills) |

```bash
/plugin install rails-toolkit@dgalarza-workflows
```

---

## Using Plugins

Skills and agents activate automatically when relevant. Commands use the plugin namespace:

```bash
# Rails toolkit commands
/rails-toolkit:full-code-review
/rails-toolkit:linear-worktree myproject TRA-9
```

---

## Manual Installation

If you prefer to copy files manually:

1. Clone this repo
2. Copy the desired plugin folder contents into your project's `.claude/` directory

```bash
# Example: Install tdd-workflow manually
cp -r plugins/tdd-workflow/skills/tdd-workflow ~/.claude/skills/
```

---

## Updating & Uninstalling

```bash
# Update a plugin
/plugin update tdd-workflow@dgalarza-workflows

# Uninstall a plugin
/plugin uninstall tdd-workflow@dgalarza-workflows
```
