# Dependabot Analyzer

Automated Dependabot PR triage for Claude Code. Fans out parallel agents to assess upgrade risk, auto-merges safe patches, diagnoses CI failures, and creates issues for PRs needing human attention.

## What It Does

1. **Discovers** all open Dependabot PRs in your repository (or multiple repos)
2. **Analyzes** each PR in parallel — reviewing changelogs, assessing risk, checking dependency health
3. **Auto-merges** safe updates (configurable thresholds)
4. **Diagnoses CI failures** and attempts mechanical fixes when possible
5. **Creates issues** in GitHub or Linear for updates that need human review

## Installation

```bash
claude install-skill dgalarza/claude-code-workflows/plugins/dependabot-analyzer
```

## Usage

Run the skill manually:

```
/dependabot-analyzer
```

Or set up a recurring schedule:

```
/schedule "Dependabot triage" --cron "0 9 * * 1" --prompt "/dependabot-analyzer"
```

## Configuration

Create `.claude/dependabot-analyzer.json` in your project root:

```json
{
  "auto_merge": {
    "enabled": true,
    "max_semver": "patch",
    "require_ci_pass": true,
    "exclude_packages": ["react", "next"]
  },
  "issue_tracker": "github",
  "labels": ["dependabot-analyzer"],
  "batch_size": 8,
  "repos": ["."],
  "risk_thresholds": {
    "create_issue_above": 40,
    "block_merge_above": 80
  }
}
```

All fields are optional — sensible defaults apply when omitted. See `skills/dependabot-analyzer/assets/config-schema.json` for the full schema with descriptions and defaults.

### Linear Integration

To use Linear as your issue tracker:

```json
{
  "issue_tracker": "linear",
  "linear_config": {
    "team_id": "YOUR_TEAM_ID",
    "project_id": "YOUR_PROJECT_ID",
    "label_ids": ["label-1", "label-2"]
  }
}
```

Requires Linear MCP tools to be available. Falls back to GitHub Issues if not configured.

## Risk Scoring

Each PR is scored from 0--100 across seven weighted factors (semver bump, CI status, breaking changes, dependency health, dep location, diff size, transitive impact) with override rules for security fixes and major framework upgrades. See `skills/dependabot-analyzer/references/risk-model.md` for the full rubric and point values.

## CI Failure Handling

Failing CI is classified as upgrade-related (fixable), pre-existing (skipped), or infrastructure (skipped). Upgrade-related failures are auto-fixed when the change is mechanical and affects fewer than 5 files. See `skills/dependabot-analyzer/references/ci-diagnosis-guide.md` for the full diagnosis protocol.

## Requirements

- `gh` CLI authenticated with repo access
- `python3` available on PATH (used by discovery and health-check scripts)
- Dependabot enabled on the target repository
- For Linear integration: Linear MCP tools configured
