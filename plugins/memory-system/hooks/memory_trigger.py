#!/usr/bin/env python3
"""
UserPromptSubmit hook: Detect memory-worthy phrases in user prompts.

Pattern-matches on user prompts to detect:
- Explicit save requests: "remember this", "save to memory", "note this down"
- Context switches: "switching to", "let's work on something else"
- Session endings: "that's all", "done for today", "goodbye"

Output: additionalContext with a targeted save reminder based on which pattern matched.
"""

import json
import re
import sys


# Pattern groups with their corresponding reminders
PATTERNS = [
    {
        "name": "explicit_save",
        "patterns": [
            r"\bremember\s+this\b",
            r"\bsave\s+(to\s+)?memory\b",
            r"\bnote\s+this\s+down\b",
            r"\bsave\s+this\b",
            r"\bdon'?t\s+forget\b",
            r"\bkeep\s+in\s+mind\b",
            r"\bwrite\s+this\s+down\b",
            r"\bstore\s+this\b",
        ],
        "reminder": (
            "The user wants to save something to memory. "
            "Write the relevant information to your memory files:\n"
            "- For session context: append to `memory/daily/{today}.md`\n"
            "- For durable knowledge: write to `memory/topics/{topic}.md`\n"
            "- For frequently-needed facts: update `memory/MEMORY.md` (keep under 200 lines)\n"
            "Read the target file first to avoid duplicates, then append concisely."
        ),
    },
    {
        "name": "context_switch",
        "patterns": [
            r"\bswitch(ing)?\s+to\b",
            r"\blet'?s\s+work\s+on\s+(something\s+else|a\s+different)\b",
            r"\bmoving\s+on\s+to\b",
            r"\bchanging\s+(topic|focus|gears)\b",
            r"\bnew\s+topic\b",
        ],
        "reminder": (
            "Context switch detected. Before changing focus, consider saving "
            "any important decisions, progress, or active context from the current work. "
            "Write a brief summary to `memory/daily/{today}.md` capturing what was accomplished "
            "and any pending next steps. Update `memory/topics/active-context.md` with the new focus area."
        ),
    },
    {
        "name": "session_end",
        "patterns": [
            r"\bthat'?s\s+all\b",
            r"\bdone\s+for\s+(today|now|the\s+day)\b",
            r"\bgoodbye\b",
            r"\bgood\s*night\b",
            r"\bsigning\s+off\b",
            r"\bwrap(ping)?\s+up\b",
            r"\bcall\s+it\s+a\s+day\b",
            r"\bending\s+(the\s+)?session\b",
        ],
        "reminder": (
            "Session ending detected. Before finishing, save important context:\n"
            "1. Append a session summary to `memory/daily/{today}.md` with:\n"
            "   - Key decisions made\n"
            "   - Files created or modified\n"
            "   - Open questions or next steps\n"
            "2. Update `memory/topics/active-context.md` with what to pick up next time\n"
            "3. If any durable knowledge was established, save to appropriate topic files"
        ),
    },
]


def main():
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        print("{}")
        return

    prompt = input_data.get("prompt", "")
    if not prompt:
        print("{}")
        return

    prompt_lower = prompt.lower()

    for group in PATTERNS:
        for pattern in group["patterns"]:
            if re.search(pattern, prompt_lower):
                from datetime import date
                today = date.today().isoformat()
                reminder = group["reminder"].replace("{today}", today)

                output = {
                    "hookSpecificOutput": {
                        "hookEventName": "UserPromptSubmit",
                        "additionalContext": f"[Memory System] {reminder}"
                    }
                }
                print(json.dumps(output))
                return

    # No pattern matched
    print("{}")


if __name__ == "__main__":
    main()
