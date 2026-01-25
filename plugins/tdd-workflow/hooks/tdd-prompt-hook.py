#!/usr/bin/env python3
"""
TDD Workflow Prompt Hook

This hook checks if the user's prompt mentions TDD, testing, or test-driven
development and injects a reminder to use the tdd-workflow skill.
"""
import json
import re
import sys


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(1)

    prompt = input_data.get("prompt", "").lower()

    # Pattern to match TDD-related terms
    tdd_patterns = [
        r"\btdd\b",
        r"\btest[- ]?driven\b",
        r"\btest[- ]?first\b",
        r"\bred[- ]?green[- ]?refactor\b",
        r"\bwrite\s+(a\s+)?test",
        r"\badd\s+(a\s+)?test",
        r"\btesting\b",
        r"\bunit\s+test",
        r"\bspec\b",
    ]

    combined_pattern = "|".join(tdd_patterns)

    if re.search(combined_pattern, prompt):
        print("Use tdd-workflow")

    sys.exit(0)


if __name__ == "__main__":
    main()
