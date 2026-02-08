#!/usr/bin/env python3
"""
SessionStart hook: Load recent daily logs and active context into new sessions.

Reads today's and yesterday's daily logs from the project's memory directory,
plus any active-context.md topic file, and injects them as additionalContext.

Input (stdin JSON):
  - cwd: current working directory
  - session_id, transcript_path, etc.

Output (stdout JSON):
  - hookSpecificOutput.additionalContext: combined recent memory text
"""

import json
import os
import sys
from datetime import date, timedelta
from pathlib import Path


def derive_memory_path(cwd: str) -> Path:
    """Derive the Claude auto-memory path from the working directory."""
    # Claude Code stores auto-memory at:
    # ~/.claude/projects/{sanitized_cwd}/memory/
    # where sanitized_cwd replaces / and spaces with - (keeps leading -)
    sanitized = cwd.replace("/", "-").replace(" ", "-")
    return Path.home() / ".claude" / "projects" / sanitized / "memory"


def read_file_safe(path: Path, max_chars: int = 0) -> str:
    """Read a file, returning empty string if it doesn't exist."""
    try:
        content = path.read_text(encoding="utf-8").strip()
        if max_chars > 0 and len(content) > max_chars:
            content = content[:max_chars] + "\n... (truncated)"
        return content
    except (FileNotFoundError, PermissionError):
        return ""


def main():
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        # No valid input, exit gracefully
        print("{}")
        return

    cwd = input_data.get("cwd", os.getcwd())
    memory_dir = derive_memory_path(cwd)
    daily_dir = memory_dir / "daily"

    if not daily_dir.exists():
        print("{}")
        return

    parts = []
    total_budget = 3000  # chars
    remaining = total_budget

    # Load today's daily log
    today = date.today()
    today_file = daily_dir / f"{today.isoformat()}.md"
    today_content = read_file_safe(today_file)
    if today_content:
        section = f"### Today ({today.isoformat()})\n{today_content}"
        parts.append(section)
        remaining -= len(section)

    # Load yesterday's daily log
    yesterday = today - timedelta(days=1)
    yesterday_file = daily_dir / f"{yesterday.isoformat()}.md"
    yesterday_content = read_file_safe(yesterday_file, max_chars=max(remaining - 500, 500))
    if yesterday_content:
        section = f"### Yesterday ({yesterday.isoformat()})\n{yesterday_content}"
        parts.append(section)
        remaining -= len(section)

    # Load active context topic file
    active_ctx_file = memory_dir / "topics" / "active-context.md"
    active_content = read_file_safe(active_ctx_file, max_chars=max(remaining, 300))
    if active_content:
        section = f"### Active Context\n{active_content}"
        parts.append(section)

    if not parts:
        print("{}")
        return

    context = "## Recent Memory (auto-loaded)\n\n" + "\n\n".join(parts)

    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context
        }
    }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
