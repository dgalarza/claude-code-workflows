#!/usr/bin/env python3
"""
Stop hook: Extract session summary from transcript and append to daily log.

On session stop, this hook:
1. Reads the transcript JSONL file
2. Parses assistant messages from the last ~50 entries
3. Extracts heuristic-based summary (decisions, file ops, next steps)
4. Appends summary to memory/daily/YYYY-MM-DD.md

This runs AFTER Claude's turn ends, so it does its own text extraction
without Claude involvement. Keeps it heuristic and simple.

Important: Checks stop_hook_active to prevent infinite loops.
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


# Keywords that indicate noteworthy content
DECISION_KEYWORDS = [
    "decided", "chose", "selected", "will use", "going with",
    "settled on", "picked", "opted for", "agreed to", "confirmed",
]
FILE_OP_KEYWORDS = [
    "created", "edited", "modified", "updated", "deleted",
    "wrote", "added", "removed", "refactored", "renamed",
]
NEXT_STEP_KEYWORDS = [
    "next step", "todo", "to do", "remaining", "still need",
    "follow up", "come back to", "later", "tomorrow",
]


def derive_memory_path(cwd: str) -> Path:
    """Derive the Claude auto-memory path from the working directory."""
    # Claude Code replaces / and spaces with - (keeps leading -)
    sanitized = cwd.replace("/", "-").replace(" ", "-")
    return Path.home() / ".claude" / "projects" / sanitized / "memory"


def extract_text_from_content(content) -> str:
    """Extract plain text from message content (handles string and list formats)."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(block.get("text", ""))
            elif isinstance(block, str):
                parts.append(block)
        return "\n".join(parts)
    return ""


def extract_summary_lines(text: str) -> dict:
    """Extract noteworthy lines from text using keyword heuristics."""
    decisions = []
    file_ops = []
    next_steps = []

    for line in text.split("\n"):
        line_lower = line.lower().strip()
        if not line_lower or len(line_lower) < 10:
            continue

        if any(kw in line_lower for kw in DECISION_KEYWORDS):
            cleaned = line.strip()[:200]
            if cleaned not in decisions:
                decisions.append(cleaned)

        if any(kw in line_lower for kw in FILE_OP_KEYWORDS):
            cleaned = line.strip()[:200]
            if cleaned not in file_ops:
                file_ops.append(cleaned)

        if any(kw in line_lower for kw in NEXT_STEP_KEYWORDS):
            cleaned = line.strip()[:200]
            if cleaned not in next_steps:
                next_steps.append(cleaned)

    return {
        "decisions": decisions[:5],
        "file_ops": file_ops[:10],
        "next_steps": next_steps[:5],
    }


def format_summary(summary: dict) -> str:
    """Format extracted summary into markdown."""
    parts = []

    if summary["decisions"]:
        parts.append("**Decisions:**")
        for item in summary["decisions"]:
            parts.append(f"- {item}")

    if summary["file_ops"]:
        parts.append("**File Operations:**")
        for item in summary["file_ops"]:
            parts.append(f"- {item}")

    if summary["next_steps"]:
        parts.append("**Next Steps:**")
        for item in summary["next_steps"]:
            parts.append(f"- {item}")

    return "\n".join(parts)


def main():
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        print("{}")
        return

    # Prevent infinite loops - if stop hook is already active, exit
    if input_data.get("stop_hook_active"):
        print("{}")
        return

    transcript_path = input_data.get("transcript_path", "")
    cwd = input_data.get("cwd", os.getcwd())

    if not transcript_path or not os.path.exists(transcript_path):
        print("{}")
        return

    memory_dir = derive_memory_path(cwd)
    daily_dir = memory_dir / "daily"

    # Read last ~50 lines of transcript
    try:
        with open(transcript_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        # Take last 50 JSONL entries
        recent_lines = lines[-50:]

        # Extract assistant message text
        all_text = []
        for line in recent_lines:
            try:
                entry = json.loads(line.strip())
                if entry.get("role") == "assistant":
                    text = extract_text_from_content(entry.get("content", ""))
                    if text:
                        all_text.append(text)
            except json.JSONDecodeError:
                continue

        if not all_text:
            print("{}")
            return

        combined_text = "\n".join(all_text)
        summary = extract_summary_lines(combined_text)

        # Only save if there's something noteworthy
        if not any(summary.values()):
            print("{}")
            return

        formatted = format_summary(summary)
        now = datetime.now()
        today_str = now.strftime("%Y-%m-%d")
        time_str = now.strftime("%H:%M")

        session_entry = f"\n## {time_str} - Session Summary (auto-extracted)\n\n{formatted}\n"

        # Ensure daily directory exists
        daily_dir.mkdir(parents=True, exist_ok=True)

        daily_file = daily_dir / f"{today_str}.md"

        if daily_file.exists():
            # Append to existing file
            with open(daily_file, "a", encoding="utf-8") as f:
                f.write(session_entry)
        else:
            # Create new daily log with header
            header = f"# Daily Log - {today_str}\n"
            with open(daily_file, "w", encoding="utf-8") as f:
                f.write(header + session_entry)

    except Exception:
        # Fail silently - don't break session end
        pass

    print("{}")


if __name__ == "__main__":
    main()
