# Structure Your CLAUDE.md Files

A well-structured `CLAUDE.md` gives Claude the context it needs to work effectively in your project. Keep it concise and focused on what matters for day-to-day development.

## Recommended Template

```markdown
# Project Name

## Overview
One paragraph on what this project does.

## Tech Stack
- Framework: Rails 7.2
- Database: PostgreSQL

## Key Patterns
- Service objects in app/services/
- Result pattern for service returns

## Testing
- RSpec with FactoryBot
- Run tests: `bin/rspec`
```

## Guidelines

- **Keep it short** - Claude reads this every session. Long files waste context.
- **Focus on conventions** - Document patterns that aren't obvious from the code itself.
- **Include run commands** - How to run tests, start the server, run migrations.
- **Skip the obvious** - Don't document standard framework conventions.
