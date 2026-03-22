#!/usr/bin/env python3
"""
Read all EML files from a ZIP archive and output them as a combined Markdown review.

Usage:
    python3 zip-review.py <archive.zip>
    python3 zip-review.py <archive.zip> --save [OUTPUT.md]
"""

import argparse
import email
import email.header
import email.policy
import html.parser
import io
import re
import sys
import zipfile
from pathlib import Path


# ── HTML → plain text ────────────────────────────────────────────────────────

class HTMLStripper(html.parser.HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self._parts = []
        self._skip = False

    def handle_starttag(self, tag, attrs):
        if tag in ("style", "script"):
            self._skip = True
        elif tag == "br":
            self._parts.append("\n")
        elif tag in ("p", "div", "tr", "li"):
            self._parts.append("\n")

    def handle_endtag(self, tag):
        if tag in ("style", "script"):
            self._skip = False

    def handle_data(self, data):
        if not self._skip:
            self._parts.append(data)

    def get_text(self):
        return re.sub(r"\n{3,}", "\n\n", "".join(self._parts)).strip()


def html_to_text(html_content: str) -> str:
    s = HTMLStripper()
    s.feed(html_content)
    return s.get_text()


# ── EML helpers ──────────────────────────────────────────────────────────────

def decode_header(value: str) -> str:
    if not value:
        return ""
    parts = email.header.decode_header(value)
    decoded = []
    for part, charset in parts:
        if isinstance(part, bytes):
            decoded.append(part.decode(charset or "utf-8", errors="replace"))
        else:
            decoded.append(part)
    return "".join(decoded)


def decode_payload(part) -> str:
    charset = part.get_content_charset() or "utf-8"
    payload = part.get_payload(decode=True)
    if payload is None:
        return ""
    try:
        return payload.decode(charset, errors="replace")
    except (LookupError, UnicodeDecodeError):
        return payload.decode("utf-8", errors="replace")


def extract_body(msg) -> str:
    plain = html = None
    if msg.is_multipart():
        for part in msg.walk():
            ct = part.get_content_type()
            if "attachment" in part.get("Content-Disposition", ""):
                continue
            if ct == "text/plain" and plain is None:
                plain = decode_payload(part)
            elif ct == "text/html" and html is None:
                html = decode_payload(part)
    else:
        ct = msg.get_content_type()
        if ct == "text/plain":
            plain = decode_payload(msg)
        elif ct == "text/html":
            html = decode_payload(msg)
    if plain:
        return plain.strip()
    if html:
        return html_to_text(html)
    return "(no body)"


def attachment_names(msg) -> list[str]:
    names = []
    if msg.is_multipart():
        for part in msg.walk():
            if "attachment" not in part.get("Content-Disposition", ""):
                continue
            fn = part.get_filename()
            if fn:
                names.append(decode_header(fn))
    return names


def eml_bytes_to_markdown(data: bytes, entry_name: str) -> str:
    msg = email.message_from_bytes(data, policy=email.policy.compat32)
    subject = decode_header(msg.get("Subject", "(no subject)"))
    from_   = decode_header(msg.get("From", ""))
    to      = decode_header(msg.get("To", ""))
    cc      = decode_header(msg.get("Cc", ""))
    date    = msg.get("Date", "")
    attaches = attachment_names(msg)

    lines = [f"**Betreff:** {subject}  "]
    lines.append(f"**Von:** {from_}  ")
    lines.append(f"**An:** {to}  ")
    if cc:
        lines.append(f"**CC:** {cc}  ")
    lines.append(f"**Datum:** {date}  ")
    if attaches:
        lines.append(f"**Anhänge:** {', '.join(attaches)}  ")
    lines.append("")
    lines.append(extract_body(msg))
    return "\n".join(lines)


# ── Main ─────────────────────────────────────────────────────────────────────

def process_zip(zip_path: Path) -> str:
    sections = []
    with zipfile.ZipFile(zip_path, "r") as zf:
        eml_entries = sorted(
            e for e in zf.namelist()
            if e.lower().endswith(".eml")
        )
        total = len(eml_entries)
        for i, entry in enumerate(eml_entries, 1):
            data = zf.read(entry)
            md = eml_bytes_to_markdown(data, entry)
            name = Path(entry).stem
            section = f"## {i}/{total} — {name}\n\n{md}"
            sections.append(section)

    header = (
        f"# Email-Review: {zip_path.name}\n\n"
        f"{total} E-Mails\n\n"
        "---\n"
    )
    return header + "\n\n---\n\n".join(sections)


def main():
    parser = argparse.ArgumentParser(description="Review all EML files in a ZIP")
    parser.add_argument("zip", help="Path to the ZIP archive")
    parser.add_argument(
        "--save", metavar="FILE", nargs="?", const="",
        help="Save output to FILE (default: <zip>.md alongside the archive)"
    )
    args = parser.parse_args()

    zip_path = Path(args.zip)
    if not zip_path.exists():
        print(f"Error: not found: {zip_path}", file=sys.stderr)
        sys.exit(1)

    output = process_zip(zip_path)

    if args.save is not None:
        out_path = Path(args.save) if args.save else zip_path.with_suffix(".md")
        out_path.write_text(output, encoding="utf-8")
        print(f"Saved: {out_path}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
