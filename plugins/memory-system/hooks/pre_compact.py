#!/usr/bin/env python3
"""
PreCompact hook: Remind Claude to flush important context before compaction.

This is the key OpenClaw innovation — giving the model a chance to persist
important state to memory files before context truncation occurs.

Output: additionalContext with a memory flush prompt.
"""

import json
import sys
from datetime import date


def main():
    today = date.today().isoformat()

    reminder = (
        "[Memory System - Pre-Compaction Flush]\n\n"
        "Context compaction is about to occur. Before losing context, "
        "save any important decisions, facts, or progress to your memory files:\n\n"
        f"- **Session context**: Append to `memory/daily/{today}.md`\n"
        "- **Durable knowledge**: Write to `memory/topics/{{topic}}.md`\n"
        "- **Frequently needed facts**: Update `memory/MEMORY.md` (keep under 200 lines)\n\n"
        "Priority items to save:\n"
        "1. Decisions made and their rationale\n"
        "2. Current task progress and what's left to do\n"
        "3. Key facts or context that would be hard to reconstruct\n"
        "4. Active file paths and their purpose\n\n"
        "Read target files first to avoid duplicates. "
        "If nothing important needs saving, continue normally."
    )

    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreCompact",
            "additionalContext": reminder
        }
    }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
