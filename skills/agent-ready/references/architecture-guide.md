# ARCHITECTURE.md Guide

Source: matklad -- "If you maintain an open-source project in the range of 10k-200k lines of code, I strongly encourage you to add an ARCHITECTURE document."

---

## Why ARCHITECTURE.md

The biggest difference between an occasional contributor and a core developer lies in knowledge about the physical architecture of the project. It takes 2x more time to write a patch if you are unfamiliar with the project, but it takes **10x more time to figure out where you should change the code**.

An ARCHITECTURE file is a low-effort, high-leverage way to bridge this gap -- for both humans and AI agents.

---

## Core Principles

### Keep It Short
Every recurring contributor (and every agent session) will read it. The shorter it is, the less likely it will be invalidated by future changes.

**Main rule of thumb:** only specify things that are unlikely to frequently change. Do not try to keep it synchronized with code. Revisit it a couple of times a year.

### Bird's Eye View of the Problem
Start with the problem being solved, not the solution. One paragraph that orients the reader on what this system does and why it exists.

### Codemap, Not Atlas
Describe coarse-grained modules and how they relate to each other. The codemap should answer:
- **"Where is the thing that does X?"**
- **"What does the thing I am looking at do?"**

Avoid going into details of how each module works. Pull that into separate documents or inline documentation. A codemap is a map of a country, not an atlas of maps of its states.

### Name Things, Don't Link Them
**Do** name important files, modules, and types. **Do not** directly link them (links go stale). Instead, encourage the reader to use symbol search to find the mentioned entities by name. This does not require maintenance and helps discover related, similarly named things.

### Document Invariants, Especially Absences
Important invariants are often expressed as an **absence** of something, and it is hard to divine that from reading code.

Examples:
- "The model layer does not depend on the view layer"
- "There is no ORM -- all database queries are hand-written SQL in `db/queries/`"
- "We do not use global state; all configuration is injected"
- "Authentication is handled entirely by the gateway; services never verify tokens directly"

### Point Out Boundaries
Boundaries between layers and systems implicitly contain information about the implementation behind them. They constrain all possible implementations. But finding a boundary by just reading code is hard -- good boundaries have measure zero.

Explicitly call out:
- Where one subsystem ends and another begins
- What is public API versus internal implementation
- Which modules are allowed to depend on which

### Cross-Cutting Concerns
After the codemap, add a section on concerns that span multiple modules:
- Error handling strategy
- Logging and observability
- Authentication and authorization
- Configuration management
- Database access patterns

---

## Structure Template

```markdown
# Architecture

## Overview
[One paragraph: what problem does this system solve?]

## Codemap
[Top-level modules with one-line descriptions]

## Invariants
[Rules that hold across the codebase, including absences]

## Boundaries
[Public API vs internal, layer dependencies]

## Cross-Cutting Concerns
[Logging, auth, errors, config -- how they work across the system]
```

---

## Anti-Patterns

- **Too detailed:** If it reads like API documentation, it is too granular. Pull details into separate docs.
- **Too volatile:** If you update it every sprint, the content is too fine-grained. Only include stable facts.
- **Links instead of names:** Links rot. Names are searchable and stable.
- **Missing absences:** The hardest invariants to discover are things that do NOT exist. Call them out.
- **No boundaries:** Without explicit boundaries, readers (and agents) cannot tell where one subsystem ends and another begins.

---

## Key Takeaway

ARCHITECTURE.md gives readers (human or agent) a mental map of the codebase. It answers "where do I look?" and "what am I looking at?" without requiring them to read every file. Keep it short, name things, document what is NOT there, and point out where systems meet.
