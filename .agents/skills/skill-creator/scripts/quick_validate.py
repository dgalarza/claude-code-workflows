#!/usr/bin/env python3
"""Quick validation script for skills."""

import re
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None


def _parse_scalar(raw_value):
    """Parse the simple scalar forms used in SKILL.md frontmatter."""
    value = raw_value.strip()

    if not value:
        return ""

    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]

    lowered = value.lower()
    if lowered == "true":
        return True
    if lowered == "false":
        return False

    return value


def parse_frontmatter(frontmatter_text):
    """Parse YAML frontmatter with a stdlib fallback for simple repo formats."""
    if yaml is not None:
        try:
            parsed = yaml.safe_load(frontmatter_text)
        except yaml.YAMLError as exc:
            raise ValueError(f"Invalid YAML in frontmatter: {exc}") from exc
        if parsed is None:
            return {}
        if not isinstance(parsed, dict):
            raise ValueError("Frontmatter must be a YAML dictionary")
        return parsed

    parsed = {}
    current_key = None

    for line_no, raw_line in enumerate(frontmatter_text.splitlines(), start=1):
        if not raw_line.strip():
            continue

        if raw_line.startswith((" ", "\t")):
            if current_key is None:
                raise ValueError(
                    f"Unsupported indentation on line {line_no} without a parent key"
                )

            stripped = raw_line.strip()
            if not stripped.startswith("- "):
                raise ValueError(
                    "PyYAML is not installed and this frontmatter uses nested YAML "
                    f"that the fallback parser cannot read (line {line_no})"
                )
            if not isinstance(parsed[current_key], list):
                raise ValueError(
                    f"Mixed scalar/list values for '{current_key}' on line {line_no}"
                )
            parsed[current_key].append(_parse_scalar(stripped[2:]))
            continue

        if ":" not in raw_line:
            raise ValueError(f"Invalid frontmatter line {line_no}: {raw_line}")

        key, raw_value = raw_line.split(":", 1)
        key = key.strip()
        value = raw_value.strip()
        current_key = key

        if not key:
            raise ValueError(f"Missing key on line {line_no}")

        if not value:
            parsed[key] = []
            continue

        parsed[key] = _parse_scalar(value)

    return parsed

def validate_skill(skill_path):
    """Basic validation of a skill"""
    skill_path = Path(skill_path)

    # Check SKILL.md exists
    skill_md = skill_path / 'SKILL.md'
    if not skill_md.exists():
        return False, "SKILL.md not found"

    # Read and validate frontmatter
    content = skill_md.read_text()
    if not content.startswith('---'):
        return False, "No YAML frontmatter found"

    # Extract frontmatter
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format"

    frontmatter_text = match.group(1)

    try:
        frontmatter = parse_frontmatter(frontmatter_text)
    except ValueError as exc:
        return False, str(exc)

    # Define allowed properties
    ALLOWED_PROPERTIES = {
        'name',
        'description',
        'license',
        'allowed-tools',
        'metadata',
        'compatibility',
        'disable-model-invocation',
    }

    # Check for unexpected properties (excluding nested keys under metadata)
    unexpected_keys = set(frontmatter.keys()) - ALLOWED_PROPERTIES
    if unexpected_keys:
        return False, (
            f"Unexpected key(s) in SKILL.md frontmatter: {', '.join(sorted(unexpected_keys))}. "
            f"Allowed properties are: {', '.join(sorted(ALLOWED_PROPERTIES))}"
        )

    # Check required fields
    if 'name' not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if 'description' not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    # Extract name for validation
    name = frontmatter.get('name', '')
    if not isinstance(name, str):
        return False, f"Name must be a string, got {type(name).__name__}"
    name = name.strip()
    if name:
        # Check naming convention (kebab-case: lowercase with hyphens)
        if not re.match(r'^[a-z0-9-]+$', name):
            return False, f"Name '{name}' should be kebab-case (lowercase letters, digits, and hyphens only)"
        if name.startswith('-') or name.endswith('-') or '--' in name:
            return False, f"Name '{name}' cannot start/end with hyphen or contain consecutive hyphens"
        # Check name length (max 64 characters per spec)
        if len(name) > 64:
            return False, f"Name is too long ({len(name)} characters). Maximum is 64 characters."

    # Extract and validate description
    description = frontmatter.get('description', '')
    if not isinstance(description, str):
        return False, f"Description must be a string, got {type(description).__name__}"
    description = description.strip()
    if description:
        # Check for angle brackets
        if '<' in description or '>' in description:
            return False, "Description cannot contain angle brackets (< or >)"
        # Check description length (max 1024 characters per spec)
        if len(description) > 1024:
            return False, f"Description is too long ({len(description)} characters). Maximum is 1024 characters."

    # Validate compatibility field if present (optional)
    compatibility = frontmatter.get('compatibility', '')
    if compatibility:
        if not isinstance(compatibility, str):
            return False, f"Compatibility must be a string, got {type(compatibility).__name__}"
        if len(compatibility) > 500:
            return False, f"Compatibility is too long ({len(compatibility)} characters). Maximum is 500 characters."

    disable_model_invocation = frontmatter.get('disable-model-invocation')
    if disable_model_invocation is not None and not isinstance(disable_model_invocation, bool):
        return False, (
            "disable-model-invocation must be a boolean, "
            f"got {type(disable_model_invocation).__name__}"
        )

    return True, "Skill is valid!"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python quick_validate.py <skill_directory>")
        sys.exit(1)
    
    valid, message = validate_skill(sys.argv[1])
    print(message)
    sys.exit(0 if valid else 1)
