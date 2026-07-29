#!/usr/bin/env python3
"""Audit a migrated LaTeX project for common structural and build problems."""

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter
from pathlib import Path


class Audit:
    def __init__(self) -> None:
        self.items: list[tuple[str, str, str]] = []

    def add(self, level: str, location: str, message: str) -> None:
        self.items.append((level, location, message))

    def report(self) -> None:
        order = {"ERROR": 0, "WARN": 1, "INFO": 2}
        for level, location, message in sorted(
            self.items, key=lambda item: (order[item[0]], item[1], item[2])
        ):
            print(f"{level:5} {location}: {message}")
        counts = Counter(level for level, _, _ in self.items)
        print(
            f"\nSummary: {counts['ERROR']} error(s), "
            f"{counts['WARN']} warning(s), {counts['INFO']} info item(s)"
        )


def strip_comment(line: str) -> str:
    match = re.search(r"(?<!\\)%", line)
    return line[: match.start()] if match else line


def reachable_tex_files(root: Path) -> list[Path]:
    """Follow input/include edges from main.tex instead of auditing unused examples."""
    entry = root / "main.tex"
    queue = [entry] if entry.is_file() else sorted(root.glob("*.tex"))
    seen: set[Path] = set()
    while queue:
        path = queue.pop(0).resolve()
        if path in seen or not path.is_file():
            continue
        seen.add(path)
        text = path.read_text(encoding="utf-8", errors="replace")
        for source in re.findall(r"\\(?:include|input)\{([^}]+)\}", text):
            candidate = (root / source)
            if not candidate.suffix:
                candidate = candidate.with_suffix(".tex")
            if candidate.is_file():
                queue.append(candidate)
    return sorted(seen)


def scan_tex(path: Path, root: Path, audit: Audit, swut: bool) -> dict[str, set[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    rel = str(path.relative_to(root))
    labels: set[str] = set()
    refs: set[str] = set()
    cites: set[str] = set()
    includes: set[str] = set()
    graphics: set[str] = set()
    in_verbatim = False
    in_table_body = False
    blank_run = 0

    for number, raw in enumerate(text.splitlines(), 1):
        line = strip_comment(raw)
        if re.search(r"\\begin\{(?:lstlisting|verbatim|minted)\}", line):
            in_verbatim = True
        if in_verbatim:
            if re.search(r"\\end\{(?:lstlisting|verbatim|minted)\}", line):
                in_verbatim = False
            continue
        if re.search(r"\\begin\{(?:tabular\*?|swuttabular|longtable|swutlongtable)\}", line):
            in_table_body = True

        location = f"{rel}:{number}"
        if not line.strip():
            blank_run += 1
            if blank_run == 3:
                audit.add("WARN", location, "three or more consecutive blank source lines")
            continue
        blank_run = 0

        if re.search(r"\\(?:subsubsection|paragraph)\s*\{", line):
            audit.add("ERROR", location, "unsupported fourth-level heading command")
        if not in_table_body and re.match(r"\s*(?:（\d+）|\(\d+\))\s*\S", line):
            audit.add("WARN", location, "manual parenthesized item; use enumerate")
        if not in_table_body and re.match(r"\s*\d+(?:\.\d+)+\s+\S", line):
            audit.add("WARN", location, "possible manually numbered heading")
        if re.match(r"\s*\[\d+\]\s+\S", line):
            audit.add("ERROR", location, "manual bibliography number detected")
        if re.search(r"原\s*Word\s*文稿|原稿内容|以下按原稿|Word\s*使用", line, re.I):
            audit.add("WARN", location, "migration commentary may have leaked into thesis")
        if swut and re.search(r"\\begin\{tabular\*?\}", line):
            audit.add("WARN", location, "raw tabular detected; use SWUT table wrappers")

        labels.update(re.findall(r"\\label\{([^}]+)\}", line))
        refs.update(re.findall(r"\\(?:ref|autoref|eqref)\{([^}]+)\}", line))
        for group in re.findall(r"\\(?:cite|parencite|textcite|nocite)\w*\{([^}]+)\}", line):
            cites.update(key.strip() for key in group.split(",") if key.strip())
        includes.update(re.findall(r"\\(?:include|input)\{([^}]+)\}", line))
        graphics.update(re.findall(r"\\includegraphics(?:\[[^]]*\])?\{([^}]+)\}", line))
        if re.search(r"\\end\{(?:tabular\*?|swuttabular|longtable|swutlongtable)\}", line):
            in_table_body = False

    return {
        "labels": labels,
        "refs": refs,
        "cites": cites,
        "includes": includes,
        "graphics": graphics,
    }


def resolve_tex_reference(root: Path, source: str) -> bool:
    candidate = root / source
    return candidate.is_file() or candidate.with_suffix(".tex").is_file()


def resolve_graphic(root: Path, source: str) -> bool:
    candidate = root / source
    if candidate.is_file():
        return True
    return any(candidate.with_suffix(ext).is_file() for ext in (".pdf", ".png", ".jpg", ".jpeg", ".eps"))


def scan_bibliography(root: Path, audit: Audit) -> set[str]:
    keys: list[tuple[str, str]] = []
    titles: list[tuple[str, str]] = []
    entry_pattern = re.compile(
        r"@\w+\s*\{\s*([^,\s]+)\s*,(.*?)(?=\n@\w+\s*\{|\Z)", re.S | re.I
    )
    for path in sorted(root.rglob("*.bib")):
        text = path.read_text(encoding="utf-8", errors="replace")
        rel = str(path.relative_to(root))
        for key, body in entry_pattern.findall(text):
            keys.append((key, rel))
            title_match = re.search(r"\btitle\s*=\s*[{\"](.+?)[}\"]\s*,?\s*$", body, re.M | re.I)
            if title_match:
                normalized = re.sub(r"[\s{}\\]+", "", title_match.group(1)).lower()
                if normalized:
                    titles.append((normalized, f"{rel}:{key}"))

    key_counts = Counter(key for key, _ in keys)
    for key, count in key_counts.items():
        if count > 1:
            audit.add("ERROR", "bibliography", f"duplicate key {key!r} ({count} entries)")
    title_groups: dict[str, list[str]] = {}
    for title, location in titles:
        title_groups.setdefault(title, []).append(location)
    for locations in title_groups.values():
        if len(locations) > 1:
            audit.add("WARN", "bibliography", "possible duplicate title: " + ", ".join(locations))
    return {key for key, _ in keys}


def scan_log(root: Path, audit: Audit) -> None:
    logs = sorted(root.glob("*.log"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not logs:
        audit.add("WARN", ".", "no top-level LaTeX log found; compile the project")
        return
    path = logs[0]
    text = path.read_text(encoding="utf-8", errors="replace")
    rel = str(path.relative_to(root))
    checks = [
        ("ERROR", r"^!", "LaTeX error"),
        ("ERROR", r"Undefined control sequence", "undefined control sequence"),
        ("ERROR", r"Missing character:", "missing character"),
        ("ERROR", r"Overfull \\[hv]box", "overfull box"),
        ("WARN", r"LaTeX Warning:.*undefined", "undefined reference/citation warning"),
        ("WARN", r"Font Warning:.*substitut", "font substitution warning"),
    ]
    for level, pattern, message in checks:
        count = len(re.findall(pattern, text, re.M | re.I))
        if count:
            audit.add(level, rel, f"{message} ({count})")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", type=Path)
    parser.add_argument("--strict", action="store_true", help="return failure for warnings")
    args = parser.parse_args()
    root = args.project.resolve()
    if not root.is_dir():
        parser.error(f"directory not found: {root}")

    audit = Audit()
    tex_files = reachable_tex_files(root)
    if not tex_files:
        audit.add("ERROR", ".", "no LaTeX source files found")

    swut = (root / "swutthesis.cls").is_file()
    all_labels: list[str] = []
    all_refs: set[str] = set()
    all_cites: set[str] = set()
    all_includes: set[str] = set()
    all_graphics: set[str] = set()
    for path in tex_files:
        found = scan_tex(path, root, audit, swut)
        all_labels.extend(found["labels"])
        all_refs.update(found["refs"])
        all_cites.update(found["cites"])
        all_includes.update(found["includes"])
        all_graphics.update(found["graphics"])

    label_counts = Counter(all_labels)
    for label, count in label_counts.items():
        if count > 1:
            audit.add("ERROR", "labels", f"duplicate label {label!r} ({count} definitions)")
    missing_refs = sorted(all_refs - set(all_labels))
    for label in missing_refs:
        audit.add("ERROR", "references", f"undefined label {label!r}")

    for source in sorted(all_includes):
        if not resolve_tex_reference(root, source):
            audit.add("ERROR", "includes", f"missing source {source!r}")
    for source in sorted(all_graphics):
        if not resolve_graphic(root, source):
            audit.add("ERROR", "graphics", f"missing image {source!r}")

    bib_keys = scan_bibliography(root, audit)
    for key in sorted(all_cites - bib_keys - {"*"}):
        audit.add("ERROR", "citations", f"undefined bibliography key {key!r}")

    main_candidates = sorted(root.glob("*.tex"))
    main_text = "\n".join(
        path.read_text(encoding="utf-8", errors="replace") for path in main_candidates
    )
    if swut:
        match = re.search(r"\\supervisor\{([^}]*)\}", main_text)
        if match is None or not match.group(1).strip():
            audit.add("ERROR", "metadata", "SWUT supervisor metadata is missing")
    if not list(root.glob("*.pdf")):
        audit.add("WARN", ".", "no top-level PDF found")

    scan_log(root, audit)
    if not audit.items:
        audit.add("INFO", ".", "no common migration problems detected")
    audit.report()
    has_error = any(level == "ERROR" for level, _, _ in audit.items)
    has_warning = any(level == "WARN" for level, _, _ in audit.items)
    return 1 if has_error or (args.strict and has_warning) else 0


if __name__ == "__main__":
    raise SystemExit(main())
