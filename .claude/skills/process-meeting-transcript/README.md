# Process Meeting Transcript Skill

A Claude Code skill for transforming raw meeting transcripts into structured Obsidian notes with frontmatter, action items, summaries, and formatted transcripts.

## Quick Start

This skill helps you convert unstructured meeting transcripts (from Granola or other sources) into well-organized notes that enable:
- Easy extraction of action items and commitments
- Quick reference of key decisions and topics
- Searchable meeting history with proper metadata
- Consistent formatting across all meeting notes

## What It Does

The skill processes raw transcripts and generates:

1. **YAML Frontmatter** - Structured metadata with attendees, date, topics, and tags
2. **Action Items** - Extracted commitments and tasks with assigned owners
3. **Summary** - Concise overview of discussions, decisions, and outcomes
4. **Formatted Transcript** - Clean, readable version of the original transcript

## Usage in Claude Code

Simply provide a transcript to Claude and ask to process it:

```bash
# If the transcript is in a file
"Process the meeting transcript in meeting-notes.txt"

# If you paste the transcript directly
"Process this meeting transcript: [paste transcript here]"
```

Claude will automatically:
- Extract all action items and commitments
- Identify key decisions and topics
- Generate comprehensive frontmatter
- Create a well-structured Obsidian note

## Example Output Structure

```markdown
---
title: Billing System Architecture Review
date: 2024-10-28
type: meeting
attendees: ['Alice', 'Bob', 'Charlie']
project: Billing System Redesign
tags: [meeting, billing, architecture]
status: complete
key_topics:
  - Database schema design
  - API versioning strategy
  - Timeline and milestones
action_items:
  - 'Alice: Create RFC for billing versioning approach'
  - 'Bob: Review cascade operation requirements'
decisions:
  - Use temporal tables for version history
  - Implement command tracking for audit trail
---

# Action Items

- **Alice**: Create RFC for billing versioning approach by EOW
- **Bob**: Review cascade operation requirements and document edge cases
- **Charlie**: Schedule follow-up with infrastructure team

# Summary

The team discussed the technical approach for implementing billing system versioning...

## Database Design

We decided to use temporal tables with...

# Transcript

[Raw transcript content preserved here]
```

## Best Practices

✅ Process transcripts shortly after meetings while context is fresh
✅ Review extracted action items for completeness
✅ Ensure all key decisions are captured in summary
✅ Include links to related documents (Notion, Linear, GitHub)
✅ Tag notes appropriately for easy searching

❌ Don't skip over implicit commitments in discussions
❌ Don't omit technical details from architecture conversations
❌ Don't forget to capture timeline and deadline information

## Documentation

- **[SKILL.md](./SKILL.md)** - Complete guide with detailed workflow and formatting rules

## Features

- **Automatic Action Item Extraction** - Identifies explicit and implicit commitments
- **Smart Summarization** - Captures key decisions and technical details
- **Consistent Formatting** - Follows Obsidian note conventions
- **Rich Metadata** - Searchable frontmatter with all relevant information
- **Link Preservation** - Maintains references to Notion docs, Linear issues, etc.

## Input Formats

The skill works with:
- Raw Granola transcripts
- Plain text meeting notes
- Pasted transcript content
- Files containing transcripts
