# Meeting Transcript

Process raw meeting transcripts into structured notes with action items, summaries, and formatted output.

## Install

```bash
npx skills add dgalarza/claude-code-workflows --skill "meeting-transcript"

# Or via Claude marketplace
/plugin install meeting-transcript@dgalarza-workflows
```

## What It Does

Transforms raw meeting transcripts (from Granola, Otter, or manual notes) into well-structured documentation.

## Output Structure

```markdown
---
title: Meeting Title
date: YYYY-MM-DD
type: meeting
attendees: ['Person 1', 'Person 2']
tags: [meeting, project-name]
action_items:
  - 'Action item 1'
  - 'Action item 2'
decisions:
  - Decision 1
---

# Action Items

- **Alice & Bob**: Review the new feature implementation
- **Charlie**: Schedule knowledge transfer session

# Summary

High-level overview of what was discussed...

## Key Decisions

Details about decisions made...

# Transcript

[Raw transcript content]
```

## Extracted Elements

### Action Items
- Explicit commitments: "I'll do X"
- Assigned tasks: "Alex will review Y"
- Follow-up items: "We need to..."
- Decisions requiring action

### Summary
- Main topics discussed
- Key decisions made
- Technical approach agreed upon
- Timeline and next steps

### Frontmatter
- Meeting metadata (date, attendees, project)
- Tags for searchability
- Action items array for queries
- Related links (Notion, Linear, GitHub)

## When It Activates

- When processing meeting transcripts
- When formatting meeting notes
- When user points to a transcript file

## Tips for Best Results

1. **Be thorough with action items** - Don't miss commitments buried in discussion
2. **Capture decisions** - Explicit decisions are critical for reference
3. **Include technical details** - Preserve architecture discussions, API names
4. **Preserve links** - Notion docs, Linear issues, GitHub PRs mentioned
