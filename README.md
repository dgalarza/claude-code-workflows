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

### `/linear-worktree`

Sets up a new git worktree for a Linear issue, creating an isolated working directory for parallel development. Typically run from a parent directory containing your project repos.

- Fetches Linear issue details for proper branch naming
- Creates worktree in parallel directory structure
- Copies configuration files (`.env`, `config/master.key`)
- Runs setup process in new worktree
- Leaves you ready to run `/linear-implement`

→ [Detailed command documentation](linear-worktree.md)

### `/full-code-review`

This was extracted from a Ruby on Rails project I've been working on in my spare time. It triggers a full code review of the work on the current branch. Useful to have subagents review the work of another agent before creating a pull request.

- Checks for security issues such as multi-tenancy enforcement, SQL injection prevention and OWASP top 10 compliance.
- Ruby on Rails best practices such as RESTful design, POODR principles, service objects, and code clarity.
- Idiomatic ruby
- Proper testing

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

## 👥 Custom Claude Agents

This workflow toolkit includes specialized Claude agents designed to provide expert-level feedback and development assistance for Ruby on Rails applications. These agents are automatically invoked by workflow commands or can be used directly for targeted assistance.

### 🔍 Rails Code Reviewer (`rails-code-reviewer`)

Expert Rails code reviewer focusing on conventions, POODR principles, and idiomatic Ruby practices.

**Specializes in:**
- Rails conventions and RESTful design patterns
- POODR principles (Single Responsibility, dependency management, Tell Don't Ask)
- Modern Rails patterns (Hotwire, Turbo, ViewComponent, service objects)
- Performance optimization and N+1 query prevention
- Controller/model design and proper separation of concerns

**Used by:** `/full-code-review` command for Rails best practices analysis

### 🛡️ Rails Security Reviewer (`rails-security-reviewer`)

Security expert specializing in Rails applications with deep focus on multi-tenant architecture and ActsAsTenant implementation.

**Specializes in:**
- Multi-tenant data isolation and ActsAsTenant security
- Authentication, authorization, and session management
- XSS prevention and input validation (accounting for Rails auto-escaping)
- SQL injection prevention and secure database queries
- CSRF protection and Rails security features
- Tenant boundary enforcement and data leakage prevention

**Used by:** `/full-code-review` and `/linear-implement` commands for security analysis

### ⚡ Rails Feature Developer (`rails-feature-developer`)

Staff Rails engineer specializing in TDD-driven feature development with modern Rails and Hotwire integration.

**Specializes in:**
- Test-Driven Development with RSpec and FactoryBot
- Clean architecture using service objects and the Result pattern
- Hotwire integration (Turbo Streams, Turbo Frames, Stimulus)
- SOLID principles and maintainable code design
- Modern Rails 7+ patterns and conventions

**Used by:** `/linear-implement` command for feature implementation

### Integration with Workflow Commands

These agents work seamlessly with the workflow commands:

- **`/linear-implement`** uses both the security reviewer and feature developer agents to ensure secure, well-architected implementations
- **`/full-code-review`** leverages both reviewer agents to provide comprehensive feedback on security and Rails best practices
- Each agent maintains context and memory to avoid redundant suggestions across review cycles

The agents follow the same structured approach as the main workflow commands, providing detailed, actionable feedback that helps maintain high code quality standards throughout the development process.

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
* Git + [gh](https://cli.github.com/) GitHub CLI
* [Linear MCP](https://linear.app/changelog/2025-05-01-mcp)

```bash
/full-code-review
```

Will:
* Check memory for existing code review decisions to avoid redundant suggestions
* Launch parallel subagents for security and Rails best practices reviews
* Report back on the subagent findings to the user


📦 Requirements

* [Knowledge Graph Memory Server MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)

---

## 🧱 MCP Servers I Use or Recommend

* [BrowserMCP](https://browsermcp.io/)
* [Knowledge Graph Memory Server MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
* [Linear](https://linear.app/changelog/2025-05-01-mcp)
* [Sentry](https://docs.sentry.io/product/sentry-mcp/) 
* [Sequential Thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)
* [figma-dev-mode-mcp-server](https://www.figma.com/blog/introducing-figmas-dev-mode-mcp-server/)
