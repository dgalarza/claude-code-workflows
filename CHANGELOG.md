# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed
- **agent-ready v1.3.1** — Session Startup template now tells agents to fetch remote refs and sync with the upstream default branch using the repo's merge or rebase strategy before starting work.

## [2026.05.22] — 2026-05-22

### Added
- **agent-ready: session-startup, DoD, JSON-ledger guidance** (#38)
   - Session startup hooks for agent initialization workflows
   - Definition of Done framework for agent tasks  
   - JSON ledger tracking for agent session audit trails

## [2026.04.14] — 2026-04-14

### Added
- **Plugin: doc-sentinel** — Documentation drift detection with hooks for post-commit scanning and stop-drift reporting
- **Plugin: agent-ready v1.2.0** — Agent documentation scaffolding with AGENTS.md support (CLAUDE.md symlink), ADR maintenance instructions, domain knowledge docs
- **Plugin: codebase-readiness v1.7.0** — Codebase assessment skill with Rust and PHP language support, landing page links
- **Plugin: doc-audit** — Audit codebase documentation for accuracy and freshness
- CI workflow to validate Claude skills and JSON on PRs
- ARCHITECTURE.md, CLAUDE.md, INSTALL.md project docs
- .claude/skills directory with skills-lock.json
- Gitignore template for Claude Code projects
- README tips organized into separate linked pages

### Changed
- Updated codebase-readiness from 1.5.0 → 1.7.0 (Rust + PHP support)
- Updated agent-ready from 1.1.0 → 1.2.0 (AGENTS.md, ADR, domain knowledge)
- Improved codebase-readiness skill output based on skill-creator review

### Fixed
- Trailing comma in marketplace.json
- Incorrect btar repository link in codebase-readiness (#23)
- Removed deprecated worktree-sync plugin

### Docs
- Documented release process and versioning strategy

[2026.05.22]: https://github.com/dgalarza/claude-code-workflows/tree/2026.05.22
[2026.04.14]: https://github.com/dgalarza/claude-code-workflows/tree/2026.04.14
