---
name: stacked-prs
description: Break a large change into a chain of small, dependent pull requests using GitHub stacked pull requests and the gh stack CLI extension. Use this skill whenever the user mentions stacked PRs, stacked pull requests, a PR stack, stacking branches or commits, gh stack, splitting a large pull request into smaller reviewable PRs, chained or dependent pull requests, building new work on top of an unmerged PR, or shipping one task per PR from a larger effort.
---

# Stacked Pull Requests

Break a large code change into a chain of small, dependent pull requests that can be reviewed and merged independently, using the `gh stack` extension for GitHub CLI. Each pull request (PR) contains one focused change, reviewers see only that layer's diff, and GitHub links the PRs together as a stack with a stack map and per-layer navigation.

Source docs: [About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs) · [Quickstart](https://docs.github.com/en/pull-requests/get-started/stacked-prs-quickstart) · [Managing stacks](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/managing-stacked-pull-requests)

This feature is in public preview and may need to be enabled for the repository. If commands fail with exit code 9 ("stacked pull requests are not enabled"), report that to the user rather than working around it.

## How stacks work

A stack is two or more PRs in the same repository where the bottom PR targets the trunk (usually the default branch) and every PR above it targets the branch of the PR below:

```text
   ┌── feat/frontend     → PR #3 (base: feat/api-endpoints)  ← top
  ┌── feat/api-endpoints → PR #2 (base: feat/auth-layer)
 ┌── feat/auth-layer     → PR #1 (base: main)               ← bottom
main (trunk)
```

**The key principle:** if code in one layer depends on code in another, the dependency must live in the same branch or a lower one. This drives every layering decision:

- Foundational changes go low: shared types, database schema, core logic, configuration.
- Code that depends on them goes high: API routes, UI components, tests that exercise the whole thing.
- Start a new layer when you switch to a different concern (backend → frontend, core logic → tests) or when the current branch is already large enough to review.

Layer well up front. Restructuring a stack later is possible but costs a restructure cycle (see "Restructuring a stack" below), while adding the next layer on top is always cheap.

Constraints to know before starting:

- All branches must be in the same repository. Cross-fork stacks are not supported.
- Not supported in GitHub Desktop. Works in GitHub CLI, the GitHub website, GitHub Mobile, and via REST/GraphQL/webhooks.
- CI checks and branch protection rules for the trunk run and are enforced on every PR in the stack, not just the bottom one.

## Prerequisites and setup

Requires GitHub CLI (`gh`) 2.90.0 or later, Git 2.20 or later, and authentication via `gh auth login`.

Install the extension once per machine:

```shell
gh extension install github/gh-stack
```

The extension reuses `gh` authentication — no separate login. `gh stack init` also enables `git rerere` automatically, so conflict resolutions are remembered across rebases.

## Core workflow

1. **Initialize the stack** from the repository root. This creates a tracking entry and the first branch.

   ```shell
   gh stack init                    # interactive: prompts for a branch name
   gh stack init feature-auth       # non-interactive: name the first branch
   gh stack init --base develop feature-auth   # target a non-default trunk
   ```

   Existing branches are adopted automatically; missing ones are created. `gh stack init b1 b2 b3` builds the whole stack at once.

2. **Work and commit** on the current branch with normal Git commands.

3. **Add a layer** when the next logical unit of work starts. Run this from the topmost branch:

   ```shell
   gh stack add api-routes
   gh stack add -Am "Add login endpoint"   # stage all + commit + branch in one step
   ```

   The `-Am` shorthand has a useful quirk: if the current branch has no commits yet, the commit lands on the current branch; if it already has commits, a new branch is created on top. Omitting the branch name with `-m` auto-generates one like `03-24-add_login` — prefer explicit names.

4. **Push all branches:**

   ```shell
   gh stack push
   ```

5. **Create and link the PRs:**

   ```shell
   gh stack submit
   ```

   This pushes branches, creates a PR per branch with the correct base, and links them as a stack on GitHub. Re-running it updates existing PRs and adds new branches to the existing stack; if every PR has merged, it starts a fresh stack rooted at the trunk.

6. **Inspect the stack** at any time:

   ```shell
   gh stack view --short   # one line per branch
   gh stack view --json    # machine-readable
   ```

## Non-interactive and agent guidance

Several commands open full-screen interactive editors. In a non-interactive terminal (or as an agent driving a shell), behavior changes in ways that matter:

- **Inspecting:** always use `gh stack view --short` or `--json`. Bare `gh stack view` opens a full-screen UI in an interactive terminal. Exit code 2 means the current branch is not in a stack — useful for detecting stack state.
- **Submitting:** `gh stack submit` in a non-interactive terminal behaves like `--auto`: it skips the editor and uses auto-generated titles. New PRs are created as **drafts** unless you pass `--open`. Drafts are usually the right default for agent-authored work; pass `--open` when the user wants PRs ready for review immediately.
- **Restructuring:** `gh stack modify` and `gh stack switch` are interactive-only TUIs. Do not attempt to drive them. Use the non-interactive restructure pattern below instead.
- **Syncing:** `gh stack sync` aborts (exiting successfully, pushing nothing) when local and remote stacks have diverged and the terminal is non-interactive. Resolve divergence by unstacking and recreating (see below).
- **Merging:** `gh stack merge` prompts in an interactive terminal. Use `--yes` plus a merge-method flag (`--merge`, `--squash`, `--rebase`) to merge without prompts.
- **Environment:** if colored output or hyperlinks misbehave in the agent's terminal, `GH_STACK_HYPERLINKS=0` disables OSC 8 hyperlinks and `GH_STACK_THEME=light|dark` forces a palette.

Exit codes are how commands tell you what went wrong — script against them:

| Code | Meaning |
| ---- | ------- |
| 0 | Success |
| 1 | Generic error |
| 2 | Not in a stack, or stack not found |
| 3 | Rebase conflict |
| 4 | GitHub API failure |
| 5 | Invalid arguments or flags |
| 6 | Branch belongs to multiple stacks; disambiguation required |
| 7 | Rebase already in progress |
| 8 | Stack locked by another process |
| 9 | Stacked pull requests not enabled for this repository |
| 10 | Modify session interrupted; recovery required |

## Common operations

### Navigate between layers

```shell
gh stack up            # one layer away from the trunk
gh stack down          # one layer toward the trunk
gh stack top           # jump to the top branch
gh stack bottom        # jump to the bottom branch
gh stack trunk         # jump to the trunk (e.g. main)
gh stack checkout BRANCH
```

All navigation clamps to the bounds of the stack. `gh stack checkout` also accepts a stack number, PR number, or PR URL, and can pull down a remote-only stack locally.

### Change the top layer

Commit on the current branch, then push:

```shell
git add ... && git commit -m "..."
gh stack push
```

### Change a lower layer

When a fix belongs in a layer below where you are working, put it where it belongs and cascade the change upward — don't work around it at the current layer:

```shell
gh stack down                     # or: gh stack checkout BRANCH
# ... edit ...
git add ... && git commit -m "..."
gh stack rebase --upstack         # replay layers above onto the fix
gh stack push
gh stack top                      # return to where you were
```

### Rebase and resolve conflicts

A stack must be linear before it can merge. `gh stack rebase` fetches from the remote and cascades a rebase from the trunk upward so every branch picks up all lower layers. Scope it with `--downstack` (trunk → current) or `--upstack` (current → top); `--no-trunk` skips the fetch and trunk rebase.

On conflict the command stops, prints conflicted files with line numbers, and exits with code 3:

```shell
# resolve markers in the listed files, then:
git add <resolved-files>
gh stack rebase --continue
# or start over:
gh stack rebase --abort
```

Then `gh stack push` — it uses per-branch `--force-with-lease`, which is the safe way to update rebased branches. Never bypass it with a manual `git push --force`.

If the repository requires signed commits, always rebase locally with `gh stack rebase` rather than the website's "Rebase stack" button — server-side rebase commits are unsigned.

### Sync after merges

When the bottom PR merges, bring local state up to date in one command:

```shell
gh stack sync --prune
```

This fetches, fast-forwards the trunk, rebases remaining branches if the trunk moved, pushes, syncs PR status, and (with `--prune`) deletes local branches for merged PRs. Remaining PRs automatically re-target the trunk. Clean remote-ahead updates (PRs someone added on GitHub) are pulled automatically; `sync` is safe in automation and only stops for true divergence.

### Restructure a stack

Human-interactive path: `gh stack modify` opens a TUI (drop `x`, fold down `d`, fold up `u`, insert `i`/`I`, rename `r`, reorder `Shift+↑`/`Shift+↓`, undo `z`, apply `Ctrl+S`). It requires an active stack, a clean working tree, no rebase in progress, no PR queued for merge, and linear history. After conflicts, `gh stack modify --continue` or `--abort`; then `gh stack submit` to rebuild the stack on GitHub.

Non-interactive path (agents, CI, or when the TUI is impractical):

```shell
gh stack unstack          # dissolve the stack on GitHub; PRs keep their bases
gh stack init b1 b2 b3    # recreate with the desired order; existing branches adopted
gh stack submit --auto    # push, recreate PRs and the stack
```

`gh stack link` is a third option that links branches or PR numbers into a stack on GitHub with no local tracking — designed for people managing branches with Jujutsu, Sapling, or git-town.

### Merge

PRs must merge from the bottom up, but you can drive that with one command. `gh stack merge` merges every PR in the stack up to and including the one you choose, as a single all-or-nothing operation:

```shell
gh stack merge 42                 # everything up to and including PR 42
gh stack merge --yes --squash     # whole current stack, no prompts
gh stack merge 7                  # by stack number, without checking it out
```

Merging the top PR merges the whole stack; merging a mid-stack PR merges everything below it while PRs above stay open and re-target the trunk. Merge commit, squash, and rebase methods are supported and merge-queue aware. Merge requirements cannot be bypassed — GitHub evaluates branch protection and rules when the merge runs.

## Command quick reference

| Command | Purpose |
| ------- | ------- |
| `gh stack init` | Initialize a stack; create/adopt the first branches |
| `gh stack add` | Add a branch on top (run from the topmost branch) |
| `gh stack submit` | Push branches, create/update PRs, link the stack |
| `gh stack push` | Push active branches (`--force-with-lease`) |
| `gh stack view` | Show branches, PR links, statuses |
| `gh stack checkout` | Check out by stack number, PR number/URL, or branch |
| `gh stack up / down / top / bottom / trunk` | Navigate the stack |
| `gh stack switch` | Interactive branch picker (TTY only) |
| `gh stack rebase` | Cascading rebase across the stack |
| `gh stack sync` | Fetch, rebase, push, sync PR state, optionally prune |
| `gh stack modify` | Interactive restructure TUI (TTY only) |
| `gh stack unstack` | Dissolve stack on GitHub and remove local tracking |
| `gh stack link` | Link branches/PRs into a stack without local tracking |
| `gh stack merge` | Merge up to and including a chosen PR |

For every command's full flags, arguments, examples, environment variables, and exit codes, read [references/cli-reference.md](references/cli-reference.md) — the complete `gh stack` command reference distilled from GitHub's docs.
