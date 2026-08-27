# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2026.08.27] — 2026-08-27

### Added
- **codebase-readiness v1.8.0** — Detects and scores regression-aware quality gates: complexity, duplication, and reliable dead-code checks, baseline treatment of legacy debt, merge-base-aware PR CI that blocks new or worsened debt, reproducible local commands, and tests of the gate. Reconnaissance assigns a single Gate Maturity Level (L0–L4) that Code Clarity, Consistency, Feedback Loops, and Change Safety each score from one distinct slice, so nothing is double-counted; top-band credit requires CI that blocks, not report-only tooling. Also detects flat ESLint/Biome configs and excludes build output from file counts.
- **agent-ready v1.5.0** — New `quality-gates` mode installs a regression-aware gate using the project's native tools (native baseline/diff modes where they exist, otherwise a stdlib engine with fingerprinted findings): `report` / `check` / `baseline` commands exposed through the task runner, merge-base-aware CI with PR annotations, CODEOWNERS protection, a docs guide, AGENTS.md Definition of Done directives, and a self-test proving unchanged legacy debt passes, new or worsened debt fails, and stale baseline entries are pruned. Baselines require a written reason and human `--approve`; agents never bless debt. Integrated into scaffold and audit. Cross-language adapter recipes for TypeScript/JavaScript, Ruby, Python, Go, JVM, Rust, and PHP; the engine template has 19 unit tests run in CI.

## [2026.08.23] — 2026-08-23

### Added
- **agent-ready v1.4.0** — Detects supported frameworks, services, and infrastructure, recommends curated project skills, and installs confirmed selections locally with `npx skills add`. Includes React, React Native, Angular, Svelte, Mastra, FastAPI, Laravel, Supabase, Stripe, Cloudflare Workers, Terraform, and optional UI guidance.

## [2026.05.26] — 2026-05-26

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

[2026.08.23]: https://github.com/dgalarza/claude-code-workflows/tree/2026.08.23
[2026.05.26]: https://github.com/dgalarza/claude-code-workflows/tree/2026.05.26
[2026.05.22]: https://github.com/dgalarza/claude-code-workflows/tree/2026.05.22
[2026.04.14]: https://github.com/dgalarza/claude-code-workflows/tree/2026.04.14
