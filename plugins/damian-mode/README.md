# Damian Mode

My working conventions for coding agents, packaged as a skill. It covers how agents reply, when they act without asking, how they delegate and pick models, what counts as done, and how work moves from a Linear ticket to a merged PR.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "damian-mode"

# Or via Claude marketplace
/plugin install damian-mode@dgalarza-workflows
```

## Usage

The skill only loads on request. Start a session with `/damian-mode`, or put it at the top of an agent's brief.

## What It Covers

| Section | Summary |
|---------|---------|
| Response style | Answer first, plain language, options with a recommendation |
| Writing | Human copy, Simplified Technical English for PRs and RCAs, reviewable output |
| Autonomy | What proceeds without asking, and what waits for approval |
| Delegation | Orchestrator role, written briefs, one writer per file set |
| Models | Which Claude Code and Codex model handles which task |
| Verification | End-to-end checks on the real interface, with proof |
| Process | Linear tickets, stacked PRs, independent review, automatic PR babysitting |

## Dependencies

The skill points to other skills by name. Install the ones you want it to use: `stacked-prs`, `team-code-review`, `herdr-code-review`, `issue-writer`, `spec-writer`, `no-ai-slop`, and the [pstack](https://github.com/michael-denyer/pstack-claude) plugin for `poteto-mode`, `babysit`, and `bro`.

## Make Your Own

These are one person's conventions. To build yours from your own agent history, run pstack's `/automate-me`.
