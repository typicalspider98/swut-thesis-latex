#!/usr/bin/env python3
"""Create a structural inventory of a DOCX package using the standard library."""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from collections import Counter
from pathlib import Path
from xml.etree import ElementTree as ET

NS = {
    "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "pr": "http://schemas.openxmlformats.org/package/2006/relationships",
    "cp": "http://schemas.openxmlformats.org/package/2006/metadata/core-properties",
    "dc": "http://purl.org/dc/elements/1.1/",
}


def q(prefix: str, name: str) -> str:
    return f"{{{NS[prefix]}}}{name}"


def parse_xml(package: zipfile.ZipFile, name: str) -> ET.Element | None:
    try:
        return ET.fromstring(package.read(name))
    except KeyError:
        return None


def node_text(node: ET.Element) -> str:
    chunks: list[str] = []
    for child in node.iter():
        if child.tag == q("w", "t"):
            chunks.append(child.text or "")
        elif child.tag == q("w", "tab"):
            chunks.append("\t")
        elif child.tag in {q("w", "br"), q("w", "cr")}:
            chunks.append("\n")
    return "".join(chunks).strip()


def paragraph_info(node: ET.Element, styles: dict[str, str]) -> dict:
    style_node = node.find("./w:pPr/w:pStyle", NS)
    style_id = style_node.get(q("w", "val"), "") if style_node is not None else ""
    num_node = node.find("./w:pPr/w:numPr/w:numId", NS)
    level_node = node.find("./w:pPr/w:numPr/w:ilvl", NS)
    image_ids = [
        blip.get(q("r", "embed"), "")
        for blip in node.findall(".//a:blip", NS)
        if blip.get(q("r", "embed"))
    ]
    return {
        "type": "paragraph",
        "text": node_text(node),
        "style_id": style_id,
        "style": styles.get(style_id, style_id),
        "numbering": {
            "num_id": num_node.get(q("w", "val"), "") if num_node is not None else "",
            "level": level_node.get(q("w", "val"), "") if level_node is not None else "",
        },
        "image_relationships": image_ids,
        "has_text_box": node.find(".//w:txbxContent", NS) is not None,
    }


def table_info(node: ET.Element) -> dict:
    rows: list[list[str]] = []
    for row in node.findall("./w:tr", NS):
        cells: list[str] = []
        for cell in row.findall("./w:tc", NS):
            paras = [node_text(p) for p in cell.findall("./w:p", NS)]
            cells.append("\n".join(text for text in paras if text))
        rows.append(cells)
    return {"type": "table", "rows": rows}


def load_styles(package: zipfile.ZipFile) -> dict[str, str]:
    root = parse_xml(package, "word/styles.xml")
    if root is None:
        return {}
    result: dict[str, str] = {}
    for style in root.findall("./w:style", NS):
        style_id = style.get(q("w", "styleId"), "")
        name = style.find("./w:name", NS)
        result[style_id] = (
            name.get(q("w", "val"), style_id) if name is not None else style_id
        )
    return result


def load_relationships(package: zipfile.ZipFile) -> dict[str, str]:
    root = parse_xml(package, "word/_rels/document.xml.rels")
    if root is None:
        return {}
    return {
        rel.get("Id", ""): rel.get("Target", "")
        for rel in root.findall("./pr:Relationship", NS)
    }


def supplemental_parts(package: zipfile.ZipFile) -> dict[str, list[str]]:
    result: dict[str, list[str]] = {}
    patterns = re.compile(
        r"word/(?:header\d+|footer\d+|footnotes|endnotes|comments)\.xml$"
    )
    for name in package.namelist():
        if not patterns.match(name):
            continue
        root = parse_xml(package, name)
        if root is None:
            continue
        texts = [node_text(p) for p in root.findall(".//w:p", NS)]
        result[name] = [text for text in texts if text]
    return result


def metadata(package: zipfile.ZipFile) -> dict[str, str]:
    root = parse_xml(package, "docProps/core.xml")
    if root is None:
        return {}
    fields = {}
    for prefix, tag in (("dc", "title"), ("dc", "creator"), ("cp", "lastModifiedBy")):
        node = root.find(f"./{prefix}:{tag}", NS)
        if node is not None and node.text:
            fields[tag] = node.text
    return fields


def inspect_docx(path: Path) -> dict:
    with zipfile.ZipFile(path) as package:
        document = parse_xml(package, "word/document.xml")
        if document is None:
            raise ValueError("word/document.xml is missing")
        body = document.find("./w:body", NS)
        if body is None:
            raise ValueError("document body is missing")

        styles = load_styles(package)
        relationships = load_relationships(package)
        blocks: list[dict] = []
        for child in body:
            if child.tag == q("w", "p"):
                blocks.append(paragraph_info(child, styles))
            elif child.tag == q("w", "tbl"):
                blocks.append(table_info(child))

        text_boxes = []
        for box in document.findall(".//w:txbxContent", NS):
            paras = [node_text(p) for p in box.findall("./w:p", NS)]
            text_boxes.append([text for text in paras if text])

        media = [
            {
                "package_path": name,
                "size_bytes": package.getinfo(name).file_size,
            }
            for name in package.namelist()
            if name.startswith("word/media/") and not name.endswith("/")
        ]

        paragraphs = [b for b in blocks if b["type"] == "paragraph"]
        nonempty = [p["text"] for p in paragraphs if p["text"]]
        duplicates = [
            {"text": text, "count": count}
            for text, count in Counter(nonempty).most_common()
            if count > 1 and len(text) >= 12
        ]
        manual_numbers = [
            {"index": i + 1, "text": p["text"]}
            for i, p in enumerate(paragraphs)
            if len(p["text"]) <= 80
            and re.match(
                r"^\s*(?:第[一二三四五六七八九十]+章|\d+(?:\.\d+)+|（\d+）)",
                p["text"],
            )
        ]

        image_refs = []
        for index, paragraph in enumerate(paragraphs, 1):
            for rel_id in paragraph["image_relationships"]:
                image_refs.append(
                    {
                        "paragraph": index,
                        "relationship_id": rel_id,
                        "target": relationships.get(rel_id, ""),
                    }
                )

        return {
            "source": str(path.resolve()),
            "metadata": metadata(package),
            "summary": {
                "blocks": len(blocks),
                "paragraphs": len(paragraphs),
                "empty_paragraphs": sum(not p["text"] for p in paragraphs),
                "tables": sum(b["type"] == "table" for b in blocks),
                "text_boxes": len(text_boxes),
                "media_files": len(media),
            },
            "blocks": blocks,
            "text_boxes": text_boxes,
            "media": media,
            "image_references": image_refs,
            "supplemental_parts": supplemental_parts(package),
            "possible_duplicate_paragraphs": duplicates,
            "possible_manual_numbering": manual_numbers,
        }


def md_escape(value: object) -> str:
    return str(value).replace("|", r"\|").replace("\n", " ↵ ")


def to_markdown(data: dict) -> str:
    lines = ["# DOCX inventory", "", f"- Source: `{data['source']}`"]
    for key, value in data["summary"].items():
        lines.append(f"- {key.replace('_', ' ').title()}: {value}")
    if data["metadata"]:
        lines.extend(["", "## Metadata", ""])
        for key, value in data["metadata"].items():
            lines.append(f"- {key}: {value}")

    lines.extend(["", "## Document order", ""])
    p_index = t_index = 0
    for block in data["blocks"]:
        if block["type"] == "paragraph":
            p_index += 1
            num = block["numbering"]
            flags = []
            if num["num_id"]:
                flags.append(f"num={num['num_id']}/{num['level']}")
            if block["has_text_box"]:
                flags.append("textbox")
            flag_text = f"; {', '.join(flags)}" if flags else ""
            lines.append(
                f"- P{p_index:04d} [{md_escape(block['style'])}{flag_text}]: "
                f"{md_escape(block['text']) or '∅'}"
            )
        else:
            t_index += 1
            lines.extend(["", f"### T{t_index:03d}", ""])
            for row in block["rows"]:
                lines.append("- " + " | ".join(md_escape(cell) for cell in row))
            lines.append("")

    lines.extend(["", "## Text boxes", ""])
    if data["text_boxes"]:
        for index, box in enumerate(data["text_boxes"], 1):
            lines.append(f"- TB{index:03d}: " + " / ".join(md_escape(x) for x in box))
    else:
        lines.append("- None detected")

    lines.extend(["", "## Embedded media", ""])
    if data["media"]:
        for item in data["media"]:
            lines.append(f"- `{item['package_path']}` ({item['size_bytes']} bytes)")
    else:
        lines.append("- None detected")

    lines.extend(["", "## Possible duplicate paragraphs", ""])
    if data["possible_duplicate_paragraphs"]:
        for item in data["possible_duplicate_paragraphs"]:
            lines.append(f"- {item['count']}× {md_escape(item['text'])}")
    else:
        lines.append("- None detected")

    lines.extend(["", "## Possible manual numbering", ""])
    if data["possible_manual_numbering"]:
        for item in data["possible_manual_numbering"]:
            lines.append(f"- P{item['index']:04d}: {md_escape(item['text'])}")
    else:
        lines.append("- None detected")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("docx", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    args = parser.parse_args()

    if not args.docx.is_file():
        parser.error(f"file not found: {args.docx}")
    try:
        data = inspect_docx(args.docx)
    except (zipfile.BadZipFile, ET.ParseError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    rendered = (
        json.dumps(data, ensure_ascii=False, indent=2) + "\n"
        if args.format == "json"
        else to_markdown(data)
    )
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
