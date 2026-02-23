# Customize Your Status Bar

Claude Code supports a configurable status bar that shows useful information during your session.

## Quick Setup

```bash
claude config set --global statusLineTemplate '${cwd.basename} | ${model} | ${tokenUsage}'
```

This gives you the current directory, active model, and token usage at a glance.

## Advanced Setup

For a full-featured status bar with themes, git integration, and cost tracking, see the [Status Bar Configuration](../configs/status-bar.md) guide.
