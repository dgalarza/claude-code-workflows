#!/usr/bin/env python3
"""Check local Markdown links and agent-ready documentation topology."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path.cwd()
EXCLUDED_PARTS = {".git", "node_modules", "vendor", ".bundle", "__pycache__"}
LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")


def markdown_files() -> list[Path]:
    return sorted(
        path
        for path in ROOT.rglob("*.md")
        if not any(part in EXCLUDED_PARTS for part in path.parts)
    )


def local_target(raw_target: str) -> str | None:
    target = raw_target.strip().split(maxsplit=1)[0].split("#", 1)[0]
    if not target or target.startswith(("http://", "https://", "mailto:", "#")):
        return None
    return target.strip("<>")


def check_links(errors: list[str]) -> None:
    for markdown_file in markdown_files():
        try:
            content = markdown_file.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            errors.append(f"{markdown_file.relative_to(ROOT)}: is not valid UTF-8")
            continue

        for target in LINK_RE.findall(content):
            relative_target = local_target(target)
            if relative_target is None:
                continue
            resolved = (markdown_file.parent / relative_target).resolve()
            if not resolved.exists():
                errors.append(
                    f"{markdown_file.relative_to(ROOT)}: broken link `{target}`"
                )


def check_agent_alias(errors: list[str]) -> None:
    agents = ROOT / "AGENTS.md"
    claude = ROOT / "CLAUDE.md"
    if agents.exists() and claude.exists() and not claude.is_symlink():
        errors.append("CLAUDE.md must be a symlink to AGENTS.md when both files exist")
    if claude.is_symlink() and claude.readlink() != Path("AGENTS.md"):
        errors.append("CLAUDE.md must point to AGENTS.md")


def check_context_map(errors: list[str]) -> None:
    context_map = ROOT / "CONTEXT-MAP.md"
    if not context_map.exists():
        return
    content = context_map.read_text(encoding="utf-8")
    context_targets = [
        target
        for target in LINK_RE.findall(content)
        if (local_target(target) or "").endswith("CONTEXT.md")
    ]
    if not context_targets:
        errors.append("CONTEXT-MAP.md must link to at least one CONTEXT.md file")


def main() -> int:
    errors: list[str] = []
    check_links(errors)
    check_agent_alias(errors)
    check_context_map(errors)

    if errors:
        print("Documentation check failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("Documentation check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
