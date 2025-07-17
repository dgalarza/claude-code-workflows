# Claude Code Workflows

**A Developer Workflow Toolkit Powered by Claude**

This repo contains a set of command-line tools powered by Claude, designed to automate and streamline developer workflows — from issue planning and implementation to review and pull request creation.

Each command follows a structured pattern:
- Uses Claude for planning and memory
- Interfaces with dev tools like Linear, Git, and GitHub
- Enforces quality through TDD and multi-agent review

> These are common workflows I use in my day-to-day development, and they can be easily adapted to your own projects.

---

## 🔧 Available Commands

### `/linear-implement`

Implements a Linear issue using Claude with full TDD flow, memory tracking, and subagent code reviews.

- Fetches issue from Linear  
- Plans solution with Claude  
- Implements with system + unit tests  
- Runs parallel reviews (security + Rails/OOP)  
- Opens a PR with full context  

→ [Detailed command documentation](.claude/commands/linear-implement.md)

---

## 🧠 Core Principles

- **Structured Planning**  
  Every command begins with Claude analyzing the task and generating an execution plan.

- **Agent Memory**  
  Plans and context are saved to persistent memory for traceability and later reference.

- **Subagent Reviews**  
  Claude spins up multiple role-specific subagents (security, architecture, conventions) for feedback.

- **End-to-End Automation**  
  Commands run through to completion, including testing, linting, and pull request creation.

---

## 🚀 Example

```bash
/linear-implement TRA-9
```

Will:
* Fetch Linear issue TRA-9
* Move to “In Progress”
* Create a branch
* Generate plan with Claude
* Implement with TDD
* Run subagent reviews
* Validate + open PR

📦 Requirements
* Git + gh GitHub CLI
* Linear API access + MCP tools
* Claude API access
* Ruby project with:
* bundle exec rspec
* bin/lint
