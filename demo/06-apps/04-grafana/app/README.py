#!/usr/bin/env python3
"""
README.py

Scans README.tpl for placeholders in the form @{key} or @{key=default},
prompts for values, then renders README.md.

Usage:
  python3 README.py
  python3 README.py --template README.tpl --out README.md
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from typing import Dict, List, Optional


PLACEHOLDER_RE = re.compile(r"@\{([^}]+)\}")  # matches @{...}


@dataclass(frozen=True)
class Placeholder:
    raw: str
    key: str
    default: Optional[str]


def parse_placeholder(raw: str) -> Placeholder:
    """
    Supports:
      @{name}
      @{name=default value}
    """
    if "=" in raw:
        left, right = raw.split("=", 1)
        return Placeholder(
            raw=raw,
            key=left.strip(),
            default=right,
        )

    return Placeholder(
        raw=raw,
        key=raw.strip(),
        default=None,
    )


def discover_placeholders(template_text: str) -> List[Placeholder]:
    raws = PLACEHOLDER_RE.findall(template_text)
    seen: Dict[str, Placeholder] = {}

    for raw in raws:
        ph = parse_placeholder(raw)
        if ph.key and ph.key not in seen:
            seen[ph.key] = ph

    return list(seen.values())


def prompt_values(placeholders: List[Placeholder]) -> Dict[str, str]:
    values: Dict[str, str] = {}

    for ph in placeholders:
        prompt = ph.key
        if ph.default is not None:
            prompt += f" [{ph.default}]"
        prompt += ": "

        try:
            entered = input(prompt)
        except EOFError:
            entered = ""

        if entered.strip():
            values[ph.key] = entered
        elif ph.default is not None:
            values[ph.key] = ph.default
        else:
            continue

    return values


def render(template_text: str, values: Dict[str, str]) -> str:
    def replace(match: re.Match) -> str:
        inner = match.group(1)
        ph = parse_placeholder(inner)
        return values.get(ph.key, match.group(0))

    return PLACEHOLDER_RE.sub(replace, template_text)


def main() -> int:
    parser = argparse.ArgumentParser(description="Render README.md from README.tpl using @{ } placeholders")
    parser.add_argument("--template", default="README.tpl", help="Template file path")
    parser.add_argument("--out", default="README.md", help="Output file path")
    parser.add_argument("--force", action="store_true", help="Overwrite output if it exists")
    args = parser.parse_args()

    if not os.path.exists(args.template):
        print(f"error: template not found: {args.template}", file=sys.stderr)
        return 2

    if os.path.exists(args.out) and not args.force:
        print(f"error: output exists: {args.out} (use --force to overwrite)", file=sys.stderr)
        return 2

    with open(args.template, "r", encoding="utf-8") as f:
        template_text = f.read()

    placeholders = discover_placeholders(template_text)

    if placeholders:
        print(f"Found {len(placeholders)} placeholder(s).")
        values = prompt_values(placeholders)
    else:
        values = {}

    rendered = render(template_text, values)

    with open(args.out, "w", encoding="utf-8", newline="\n") as f:
        f.write(rendered)

    print(f"Wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
