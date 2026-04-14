---
name: dependabot-analyzer
description: Automated Dependabot PR triage — fans out parallel agents to assess upgrade risk, auto-merges safe patches, diagnoses CI failures, and creates issues for PRs needing human attention. Supports GitHub Issues and Linear for issue tracking.
---

# Dependabot PR Analyzer

Analyze open Dependabot PRs across one or more repositories. Assess risk, auto-merge safe updates, diagnose CI failures, and create issues for anything requiring human review.

Work through the following phases sequentially.

---

## Phase 1: Configuration & Discovery

Execute directly — no sub-agents needed.

### Step 1: Load Configuration

Read `.claude/dependabot-analyzer.json` from the project root. If the file does not exist, use these defaults and inform the user:

```json
{
  "auto_merge": {
    "enabled": true,
    "max_semver": "patch",
    "require_ci_pass": true,
    "exclude_packages": []
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

Validate the loaded config:
- `batch_size` must be 1–10. Clamp and warn if out of range.
- `risk_thresholds.create_issue_above` must be less than `block_merge_above`. Warn if inverted.
- If `issue_tracker` is `"linear"`, verify `linear_config.team_id` is present. If missing, fall back to `"github"` with a warning.
- Apply defaults for any missing fields — never fail on a partial config.

See `assets/config-schema.json` for the full schema with descriptions and defaults.

### Step 2: Discover Open PRs

Run the discovery script for each repo in `repos`:

```bash
bash scripts/discover-prs.sh
```

For repos other than `"."`, pass the `--repo` flag:

```bash
bash scripts/discover-prs.sh --repo owner/repo
```

The script is located at `scripts/discover-prs.sh` relative to this skill's directory.

After reviewing the output, format a **PR Discovery Summary**:

```
## PR Discovery Summary

**Repository**: {repo}
**Open Dependabot PRs**: {count}

| PR | Dependency | Current → New | Bump | CI Status | Location | Days Open |
|----|------------|---------------|------|-----------|----------|-----------|
| #{n} | {name}  | {v1} → {v2}   | {type} | {status} | {loc}  | {days}    |
```

If zero PRs are found across all repos, report this to the user and stop. No further phases are needed.

If the total PR count exceeds `batch_size`, process in batches — complete one batch of analysis before starting the next.

---

## Phase 2: Parallel PR Analysis

Fan out one agent per PR for independent risk assessment. Before launching agents, read the risk scoring rubric from `references/risk-model.md` — include its full content in each agent's prompt.

### Agent Launch

Send a **single message with N Agent tool calls** (one per PR, up to `batch_size`). Each agent uses `subagent_type: "general-purpose"` with no worktree isolation (read-only analysis).

For each PR, compose the agent prompt from these parts:

**1. Role preamble:**
```
You are a dependency update risk assessor. Analyze a single Dependabot PR and produce a structured risk assessment.
```

**2. PR context** (from Phase 1 discovery):
```
## PR Context

- PR: #{number}
- Title: {title}
- Repository: {repo}
- Dependency: {dep_name}
- Ecosystem: {ecosystem}
- Current version: {current_version}
- New version: {new_version}
- Bump type: {bump_type}
- CI status: {ci_status}
- Dependency location: {prod|dev}
- Lines changed: {total_lines}
- Days open: {days_open}
```

**3. Evidence gathering instructions:**
```
## Evidence to Gather

Run these commands to collect evidence for your assessment:

1. Review the PR diff:
   gh pr diff {number} [--repo owner/repo]

2. Review the PR description and Dependabot's notes:
   gh pr view {number} [--repo owner/repo]

3. Check CI status in detail:
   gh pr checks {number} [--repo owner/repo]

4. If CI is failing, get the failure logs:
   gh run view {run_id} --log-failed [--repo owner/repo]

5. Check dependency health:
   bash {skill_dir}/scripts/check-dep-health.sh {ecosystem} {package_name}
```

**4. Risk model** (full content of `references/risk-model.md`, inlined).

**5. CI diagnosis instructions** (only include if CI status is `failing`):

Include the full content of `references/ci-diagnosis-guide.md` and add:
```
Classify the CI failure into Category 1 (upgrade-related), Category 2 (pre-existing), or Category 3 (infrastructure). If Category 1 and the fix meets all criteria in the Fix Protocol, describe the exact changes needed.
```

**6. Output format:**
```
## Required Output

Produce a structured assessment in exactly this format:

### Assessment: PR #{number} — {dependency}

**Risk Score**: {score}/100
**Risk Band**: {Safe|Low|Medium|High|Critical}
**Recommendation**: {auto-merge|create-issue|attempt-ci-fix|block}

**Factor Breakdown**:
| Factor | Points | Notes |
|--------|--------|-------|
| Semver bump | {n} | {details} |
| CI status | {n} | {details} |
| Breaking changes | {n} | {details} |
| Dependency health | {n} | {rating} |
| Dep location | {n} | {prod/dev} |
| Diff size | {n} | {lines} lines |
| Transitive impact | {n} | {count} deps |

**Override rules applied**: {list any that applied, or "None"}

**Changelog highlights**: {2-3 sentence summary of what changed}

**CI diagnosis**: {diagnosis or "N/A — CI passing"}
{If Category 1 fixable: describe the exact fix needed}

**Evidence summary**: {key observations from the diff, health check, and PR description}
```

Wait for all agents to complete before proceeding to Phase 3.

---

## Phase 3: Execute Actions

Process each PR's assessment and take the appropriate action based on the recommendation and config settings.

### Auto-Merge (recommendation: `auto-merge`)

Verify all conditions before merging:
1. `auto_merge.enabled` is `true` in config
2. Bump type is within `auto_merge.max_semver` (patch ≤ minor ≤ major)
3. Package is not in `auto_merge.exclude_packages`
4. CI is passing (if `auto_merge.require_ci_pass` is `true`)
5. Risk score is at or below `risk_thresholds.block_merge_above`

If all conditions pass:
```bash
gh pr merge {number} --squash [--repo owner/repo]
```

Note: use `--auto` instead of immediate merge when branch protection requires additional status checks that have not yet completed. The `--auto` flag queues the merge to execute once all branch protection requirements are met — it does not merge immediately.

If the risk band is "Low" (21–40), include a note in the report that the PR was auto-merged but had a non-trivial risk score — this gives the user visibility into borderline merges.

If any condition fails, downgrade to issue creation and note which condition blocked the merge.

### CI Fix Attempt (recommendation: `attempt-ci-fix`)

Only attempt when the Phase 2 agent classified the failure as Category 1 (upgrade-related) and the fix meets the Fix Protocol criteria.

Launch a **single Agent** with `isolation: "worktree"` for each fix attempt. Include in the prompt:
- The specific fix described in the Phase 2 assessment
- Instructions to check out the Dependabot branch, apply the fix, run the failing tests, and push if passing
- The full CI diagnosis guide from `references/ci-diagnosis-guide.md`

Process CI fixes **sequentially** (not in parallel) to avoid branch conflicts between related dependency updates.

If the fix succeeds, re-evaluate whether the PR now qualifies for auto-merge. If the fix fails, fall through to issue creation.

### Issue Creation (recommendation: `create-issue` or `block`, or fallback from failed conditions)

Before creating an issue, check for existing open issues from a previous run:

```bash
gh issue list --label "dependabot-analyzer" --search "PR #{number}" --state open [--repo owner/repo]
```

If a matching issue already exists, skip creation and note "existing issue found" in the report. This prevents duplicate issues when running on a schedule.

Create an issue in the configured tracker using the template from `assets/github-issue-template.md`.

**GitHub Issues**:
```bash
gh issue create --title "Review: {dependency} {current} → {new}" --body "{filled_template}" --label "{labels}" [--repo owner/repo]
```

**Linear** (when `issue_tracker` is `"linear"` and Linear MCP tools are available):
Use `mcp__linear__create_issue()` with the configured `team_id`, `project_id`, and `label_ids`.

Fill the template with:
- PR number, title, dependency details, versions
- Full risk factor breakdown from the Phase 2 assessment
- Changelog summary
- CI diagnosis (if applicable)
- Concrete next steps based on the assessment

---

## Phase 4: Consolidated Report

Read the report template from `assets/report-template.md` and fill it with data from all phases:

- **Summary metrics**: total analyzed, auto-merged, CI fixes attempted/succeeded, issues created
- **PR table**: one row per PR with risk score and action taken
- **Detailed assessments**: full Phase 2 output for each PR
- **Recommendations**: patterns observed, config tuning suggestions, follow-up actions

Present the completed report to the user.

---

## Phase 5: Follow-up

Offer two optional actions:

1. **Save the report**: Write to `DEPENDABOT_ANALYSIS.md` in the project root. Ask the user before writing.

2. **Set up recurring schedule**: Explain that this skill can run on a schedule using Claude Code's native scheduling. Suggest a cron expression based on the PR volume observed:
   - 10+ open PRs: daily at 9am (`0 9 * * *`)
   - 3–9 open PRs: twice weekly (`0 9 * * 1,4`)
   - 1–2 open PRs: weekly Monday 9am (`0 9 * * 1`)

   The user can set this up with the `/schedule` command — this skill does not manage its own scheduling.
