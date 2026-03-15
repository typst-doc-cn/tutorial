#!/usr/bin/env python3
"""Generate Typst grammar data and sync it into the portable skill."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import textwrap
from collections import OrderedDict
from pathlib import Path


CATEGORY_MAP = {
    "基本元素": {
        "id": "base-elements",
        "title": "Base Elements",
    },
    "修饰文本": {
        "id": "text-styling",
        "title": "Text Styling",
    },
    "脚本声明": {
        "id": "script-declarations",
        "title": "Script Declarations",
    },
    "脚本语句": {
        "id": "script-statements",
        "title": "Script Statements",
    },
    "脚本样式": {
        "id": "script-styling",
        "title": "Script Styling",
    },
    "脚本表达式": {
        "id": "script-expressions",
        "title": "Script Expressions",
    },
}

CATEGORY_PATTERN = re.compile(
    r"^==\s+分类：(?P<source_heading>.+?)(?:\s+<(?P<source_anchor>[^>]+)>)?\s*$",
    re.MULTILINE,
)

ENTRY_PATTERN = re.compile(
    r"""
    \(\s*\n
    \s*\[(?P<source_label>.*?)\],\s*\n
    \s*(?P<reference_expr>refs\.(?P<reference_module>[\w-]+)\.with\(reference:\s*<(?P<reference_anchor>[^>]+)>\)),\s*\n
    \s*`{3,4}typ\s*\n
    (?P<code>.*?)
    \n\s*`{3,4},\s*\n
    \s*\),
    """,
    re.DOTALL | re.VERBOSE,
)

GENERATED_BEGIN = "<!-- BEGIN GENERATED GRAMMAR LOOKUP -->"
GENERATED_END = "<!-- END GENERATED GRAMMAR LOOKUP -->"
INLINE_CODE_LIMIT = 88


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def normalize_code(raw_code: str) -> str:
    return textwrap.dedent(raw_code).strip("\n")


def lookup_key(reference_anchor: str) -> str:
    prefix = "grammar-"
    if reference_anchor.startswith(prefix):
        return reference_anchor[len(prefix) :]
    return reference_anchor


def repo_relative(path: Path, repo_root: Path) -> str:
    try:
        return Path(os.path.relpath(path.resolve(), repo_root.resolve())).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def parse_categories(source_text: str, source_path: Path, repo_root: Path) -> list[dict]:
    categories = []
    category_matches = list(CATEGORY_PATTERN.finditer(source_text))
    if not category_matches:
        raise ValueError(f"No categories found in {source_path}")

    for index, match in enumerate(category_matches):
        section_start = match.end()
        section_end = (
            category_matches[index + 1].start()
            if index + 1 < len(category_matches)
            else len(source_text)
        )
        section_text = source_text[section_start:section_end]
        source_heading = match.group("source_heading")
        english_heading = CATEGORY_MAP.get(source_heading, {}).get("title", source_heading)
        category_id = CATEGORY_MAP.get(source_heading, {}).get(
            "id",
            f"category-{index + 1}",
        )
        category = {
            "id": category_id,
            "english_heading": english_heading,
            "source_heading": source_heading,
            "source_anchor": match.group("source_anchor"),
            "heading_line": line_number(source_text, match.start()),
            "entries": [],
        }

        for entry_match in ENTRY_PATTERN.finditer(section_text):
            absolute_start = section_start + entry_match.start()
            absolute_end = section_start + entry_match.end()
            code_start = section_start + entry_match.start("code")
            code_end = section_start + entry_match.end("code")
            entry = {
                "lookup_key": lookup_key(entry_match.group("reference_anchor")),
                "source_label": entry_match.group("source_label").strip(),
                "reference": {
                    "expression": entry_match.group("reference_expr").strip(),
                    "module": entry_match.group("reference_module"),
                    "anchor": entry_match.group("reference_anchor"),
                },
                "source": {
                    "path": repo_relative(source_path, repo_root),
                    "entry_line_start": line_number(source_text, absolute_start),
                    "entry_line_end": line_number(source_text, absolute_end),
                    "code_line_start": line_number(source_text, code_start),
                    "code_line_end": line_number(source_text, code_end),
                },
                "code": normalize_code(entry_match.group("code")),
            }
            category["entries"].append(entry)

        if not category["entries"]:
            raise ValueError(
                f"No entries parsed for category '{source_heading}' in {source_path}"
            )

        categories.append(category)

    return categories


def build_catalog(source_path: Path, repo_root: Path) -> dict:
    source_text = source_path.read_text(encoding="utf-8")
    categories = parse_categories(source_text, source_path, repo_root)
    return {
        "source_path": repo_relative(source_path, repo_root),
        "category_count": len(categories),
        "entry_count": sum(len(category["entries"]) for category in categories),
        "categories": categories,
    }


def is_inline_safe(code: str) -> bool:
    return "\n" not in code and "`" not in code and len(code) <= INLINE_CODE_LIMIT


def grouped_entries(entries: list[dict]) -> list[dict]:
    groups: OrderedDict[str, list[str]] = OrderedDict()
    for entry in entries:
        groups.setdefault(entry["lookup_key"], [])
        if entry["code"] not in groups[entry["lookup_key"]]:
            groups[entry["lookup_key"]].append(entry["code"])
    return [
        {
            "lookup_key": lookup_key,
            "examples": examples,
        }
        for lookup_key, examples in groups.items()
    ]


def render_example_block(code: str) -> list[str]:
    return [
        "~~~typ",
        code,
        "~~~",
    ]


def render_skill_lookup(catalog: dict) -> str:
    lines: list[str] = []
    for category in catalog["categories"]:
        lines.extend(
            [
                f"### {category['english_heading']}",
                "",
            ]
        )
        for group in grouped_entries(category["entries"]):
            inline_examples = [code for code in group["examples"] if is_inline_safe(code)]
            if len(inline_examples) == len(group["examples"]):
                joined = "; ".join(f"`{code}`" for code in inline_examples)
                lines.append(f"- `{group['lookup_key']}`: {joined}")
                continue

            lines.append(f"- `{group['lookup_key']}`:")
            lines.append("")
            for index, code in enumerate(group["examples"]):
                lines.extend(render_example_block(code))
                if index != len(group["examples"]) - 1:
                    lines.append("")
            lines.append("")

    while lines and not lines[-1]:
        lines.pop()
    return "\n".join(lines) + "\n"


def update_skill(skill_path: Path, generated_lookup: str) -> None:
    skill_text = skill_path.read_text(encoding="utf-8")
    pattern = re.compile(
        rf"{re.escape(GENERATED_BEGIN)}\n.*?{re.escape(GENERATED_END)}",
        re.DOTALL,
    )
    replacement = f"{GENERATED_BEGIN}\n{generated_lookup}{GENERATED_END}"
    updated_text, count = pattern.subn(lambda _: replacement, skill_text, count=1)
    if count != 1:
        raise ValueError(f"Could not find generated section markers in {skill_path}")
    skill_path.write_text(updated_text, encoding="utf-8")


def write_outputs(
    catalog: dict,
    output_dir: Path,
    skill_path: Path,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    json_path = output_dir / "grammar-catalog.json"
    json_path.write_text(
        json.dumps(catalog, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    update_skill(skill_path, render_skill_lookup(catalog))
    print(f"[OK] Wrote {json_path}")
    print(f"[OK] Updated {skill_path}")


def default_source(script_path: Path) -> Path:
    return script_path.parents[4] / "src" / "tutorial" / "reference-grammar.typ"


def default_skill_path(script_path: Path) -> Path:
    return script_path.parents[2] / "typst-grammar-authoring" / "SKILL.md"


def main() -> int:
    script_path = Path(__file__).resolve()
    parser = argparse.ArgumentParser(
        description="Generate Typst grammar data from reference-grammar.typ.",
    )
    parser.add_argument(
        "--source",
        type=Path,
        default=default_source(script_path),
        help="Path to src/tutorial/reference-grammar.typ",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=script_path.parent.parent / "references",
        help="Directory for generated reference files",
    )
    parser.add_argument(
        "--skill-path",
        type=Path,
        default=default_skill_path(script_path),
        help="Path to the portable SKILL.md file to sync",
    )
    args = parser.parse_args()

    try:
        repo_root = script_path.parents[4]
        source_path = args.source.resolve()
        catalog = build_catalog(source_path, repo_root)
        write_outputs(
            catalog,
            args.output_dir.resolve(),
            args.skill_path.resolve(),
        )
    except Exception as exc:  # pragma: no cover - CLI error surface
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
