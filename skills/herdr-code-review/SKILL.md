---
name: herdr-code-review
description: Spawn a fresh reviewer agent in a new sibling pane of the current Herdr workspace, delegate a full team-code-review pass to it, then collect and relay its report. Use when the user explicitly asks for a code review in a new, separate, or fresh Herdr agent or pane, or otherwise asks to delegate a review through Herdr. Do not trigger merely because a Herdr session is detected; a plain code-review request runs team-code-review in the current agent. Requires HERDR_ENV=1.
---

# Herdr Code Review

Delegate a code review to a fresh coding agent started in a new sibling pane of the current Herdr workspace. The spawned reviewer executes the `team-code-review` skill end to end and returns its report in the pane. This skill owns only the handoff and the reviewer lifecycle; it does not perform the review itself.

## 0. Decide whether to delegate

Before spawning anything, verify delegation is actually wanted:

```bash
test "${HERDR_ENV:-}" = 1
```

- **Not inside Herdr:** say that Herdr control is unavailable and run the `team-code-review` skill in the current agent instead. Do not attempt Herdr commands.
- **Already the delegated reviewer:** if your current assigned review pass explicitly contains the marker `HERDR_CODE_REVIEW_REVIEWER=1`, you are the spawned reviewer, not the caller. Do not spawn another agent; execute `team-code-review` directly and return the report where it was requested. This prevents recursive reviewer spawning even if this skill is loaded by mistake.
- **User wants the review in the current agent:** run `team-code-review` directly without this handoff.
- **Inside Herdr and delegation is requested:** continue below.

Every new review or re-review requires a fresh agent session, including reviewing fixes or repeating an unchanged target. Never send a new pass to the old reviewer or resume its session. If a new pass is requested directly in the reviewer pane, hand control back to the original caller for replacement; do not close your own pane or review again in the existing context.

## 1. Discover the caller

Load the `herdr` skill and follow its session checks, CLI discovery, layout rules, and safety rules. If that skill is unavailable, verify `HERDR_ENV=1` and read `herdr --skill`. The installed CLI is authoritative; inspect `herdr --help`, `herdr agent`, and `herdr pane` before controlling panes.

Resolve the calling pane explicitly, never the UI-focused pane:

```bash
herdr pane current --current
herdr agent get <caller-pane-id>
```

Read the caller pane ID from `.result.pane.pane_id` and its recognized agent kind from `.result.agent.agent` in the agent-get response. Confirm the kind is supported by the installed `herdr agent` command. The reviewer must be the same agent runtime/kind as the caller: pi → pi, Claude Code → claude, Codex → codex. Do not infer it from the underlying model provider, agent name, or another pane. Do not resume or clone the caller's conversation; the reviewer needs fresh context.

If detection fails, explain the problem and ask how to proceed rather than guessing a kind. Do not silently substitute a different agent kind.

## 2. Prepare an exact handoff

Before launching, resolve enough scope to make the child's task self-contained:

- Absolute repository/worktree path and caller working directory.
- Own-work versus another contributor's PR, including PR URL/number if applicable.
- Resolved base/head commit SHAs for a committed review.
- For uncommitted work, explicitly state whether staged, unstaged, and untracked files are included, and identify the intended files/hunks. Do not substitute `HEAD` for the working-tree diff or include unrelated edits.
- User constraints, non-goals, relevant context from the conversation, and known checks already run.
- Absolute path to this installation's `team-code-review/SKILL.md` so the child loads the same version.

The child can discover repository instructions and stack profiles itself. Do not perform the full review before delegating. Keep the reviewed files unchanged while it works; if the target changes, resolve the new scope and rerun the affected review rather than presenting stale findings.

## 3. Replace the previous reviewer before each new pass

Waiting for the current pass, resolving its blocking question, or retrieving its complete report is a continuation, not a new review. Reviewing fixes or asking for another assessment is a new pass and uses a newly started agent.

The original caller owns this lifecycle. Retain the reviewer pane ID, unique agent name, kind, and session identity returned by `agent start`, together with the review target and original caller pane ID. Before replacement:

1. Preserve the previous report in the original conversation if it has completed and has not yet been relayed.
2. Inspect the recorded pane with `herdr agent get <previous-reviewer-pane-id>` and compare its live identity to the recorded reviewer. Do not identify ownership from a similar name, cwd, or kind alone. If identity cannot be verified, ask the user before closing anything. If the recorded pane is already gone, proceed without closing a substitute.
3. Close only that verified, dedicated reviewer pane with `herdr pane close <previous-reviewer-pane-id>`. This terminates the old agent; renaming it, clearing its display, or sending a reset prompt does not create a fresh session. A user-requested new pass supersedes an unfinished old pass; disclose that it is being stopped and do not report it as completed. Never close the original caller or a pane repurposed for other work.
4. Confirm closure succeeded, then launch a fresh reviewer below. If closure fails, resolve the failure before launching a duplicate.

If a re-review request arrives in the reviewer itself, direct it back to the recorded original caller for replacement. Do not self-close, recursively delegate, or let a marker from the previous pass authorize another review in the same session.

## 4. Launch one fresh reviewer in the existing workspace

Use a sibling pane in the caller's current workspace and tab. Do not create a workspace, tab, worktree, or different cwd unless requested; that is a different workflow (see `herdr-pr-review` for isolated worktree reviews of external PRs). Inspect the caller's layout and split right when wide, down when narrow/tall, keeping the caller's cwd and focus:

```bash
herdr pane layout --pane <caller-pane-id>
herdr pane split --current --direction <right-or-down> --cwd "$PWD" --no-focus
```

Read the new pane ID from `.result.pane.pane_id`. Choose a unique valid agent name after checking `herdr agent list`, then start the caller's kind in that new shell pane:

```bash
herdr agent start <reviewer-name> --kind <caller-kind> --pane <new-pane-id>
```

Record the new reviewer's returned identity for the next replacement. Do not pass resume/continue options or reuse an old conversation. If startup fails, inspect the created pane before retrying; avoid duplicate agents. Do not bypass approval or permission controls.

Submit a self-contained prompt through `herdr agent prompt`, safely quoted as a single argument, with this structure:

```text
HERDR_CODE_REVIEW_REVIEWER=1
You are the delegated reviewer, not the implementation agent. Do not spawn additional Herdr agents and do not load the herdr-code-review skill; this marker means you are already the reviewer.
Read <absolute-skill-path>/team-code-review/SKILL.md and execute that skill end to end on the target below. Use native subagents for the specialist lenses if available; otherwise investigate the six lenses sequentially and disclose that limitation.
Original caller pane: <caller-pane-id>. This assignment is one review pass only. If asked for a new review or re-review later, return control to the original caller so it can close this pane and start a fresh agent; do not reuse this session.
Target: <repository, authorship branch, PR if applicable, exact base/head or working-tree scope>
Context and constraints: <relevant caller context>
Keep the review read-only: do not edit source, stage, commit, fix findings, or draft/publish PR comments. Verify candidate findings and return the complete report, including checks performed and limitations, here in the pane.
```

## 5. Collect and return the report

Use `herdr agent prompt <reviewer-name> <prompt> --wait --timeout 120000`. A timeout is not completion: inspect `agent get` and `agent read`, then continue with `agent wait` as needed rather than resubmitting the review. For `blocked`, inspect the requested approval or question and surface anything requiring the user; do not automatically approve it. An `unknown` state is not proof of completion either.

Read the completed report with `herdr agent read <reviewer-name> --source recent-unwrapped --lines 200`. Confirm the report actually finished; an idle/done startup state alone is not a completed review. If output is truncated because the agent runs on the terminal's alternate screen, ask the reviewer to save the complete report to a temporary Markdown file and return its path, then read that file. Do not request file output in the initial prompt.

Relay the verified findings, overall assessment, checks performed, and limitations to the user, identifying the reviewer pane. The delegated reviewer is responsible for specialist verification; do not claim to have independently repeated its checks in the caller. For another contributor's PR, ask the user in the original conversation before drafting or publishing anything. Leave the pane available for inspection after completion; when the next review pass is requested, replace it using the ownership checks above.

## Guardrails

- The review is read-only. Neither the caller nor the spawned reviewer edits files, stages, commits, pushes, or publishes review comments.
- Spawn exactly one reviewer agent per review pass, in the existing workspace, with the caller's cwd.
- Preserve the user's focus with `--no-focus`.
- Parse IDs from JSON responses; never derive them from sidebar order or examples.
- Honor an explicit request to review in the current agent instead of delegating.
