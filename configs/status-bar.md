# Status Bar Configuration

I use [claude-powerline](https://github.com/Owloops/claude-powerline) for a customizable vim-style status bar in Claude Code.

## Installation

Add to your Claude Code settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "npx -y @owloops/claude-powerline@latest --style=powerline"
  }
}
```

That's it. Start a Claude session and the status line appears.

## Features

- **Usage tracking** - Session costs, billing windows, and budget alerts
- **Git integration** - Branch status and repo info
- **Token monitoring** - Real-time token and context window usage
- **Performance metrics** - Response time, message count, lines changed

## Customization

### Themes

Six built-in themes: `dark`, `light`, `nord`, `tokyo-night`, `rose-pine`, `gruvbox`

```json
{
  "statusLine": {
    "type": "command",
    "command": "npx -y @owloops/claude-powerline@latest --theme=tokyo-night"
  }
}
```

### Styles

Three separator styles: `minimal`, `powerline`, `capsule`

```json
{
  "statusLine": {
    "type": "command",
    "command": "npx -y @owloops/claude-powerline@latest --style=capsule"
  }
}
```

## Why I Use It

The token and cost tracking is helpful for knowing when to compact context. The git branch display keeps me oriented when working across multiple worktrees.

## Links

- [GitHub Repository](https://github.com/Owloops/claude-powerline)
- [Theme Gallery](https://github.com/Owloops/claude-powerline#themes)
