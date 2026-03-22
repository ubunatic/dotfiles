#!/usr/bin/env python3
"""Convert an EML file to Markdown. Prints to stdout by default."""

import argparse
import email
import email.policy
import email.header
import html.parser
import re
import sys
from pathlib import Path


class HTMLStripper(html.parser.HTMLParser):
    """Strip HTML tags and decode entities to plain text."""

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
        text = "".join(self._parts)
        return re.sub(r"\n{3,}", "\n\n", text).strip()


def decode_header(value: str) -> str:
    """Decode MIME encoded-word headers (e.g. =?UTF-8?Q?...?=) to plain text."""
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


def html_to_text(html_content: str) -> str:
    stripper = HTMLStripper()
    stripper.feed(html_content)
    return stripper.get_text()


def decode_payload(part) -> str:
    charset = part.get_content_charset() or "utf-8"
    payload = part.get_payload(decode=True)
    if payload is None:
        return ""
    try:
        return payload.decode(charset, errors="replace")
    except (LookupError, UnicodeDecodeError):
        return payload.decode("utf-8", errors="replace")


def get_attachments(msg) -> list[tuple[str, bytes]]:
    """Return list of (filename, data) for all attachments."""
    attachments = []
    if msg.is_multipart():
        for part in msg.walk():
            cd = part.get("Content-Disposition", "")
            if "attachment" not in cd:
                continue
            filename = part.get_filename()
            if filename:
                filename = decode_header(filename)
            else:
                filename = f"attachment.{part.get_content_subtype()}"
            data = part.get_payload(decode=True)
            if data:
                attachments.append((filename, data))
    return attachments


def extract_body(msg) -> str:
    plain = None
    html = None

    if msg.is_multipart():
        for part in msg.walk():
            ct = part.get_content_type()
            cd = part.get("Content-Disposition", "")
            if "attachment" in cd:
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


def eml_to_markdown(path: Path, extract_dir: Path | None = None) -> str:
    raw = path.read_bytes()
    msg = email.message_from_bytes(raw, policy=email.policy.compat32)

    date    = msg.get("Date", "")
    from_   = decode_header(msg.get("From", ""))
    to      = decode_header(msg.get("To", ""))
    cc      = decode_header(msg.get("Cc", ""))
    subject = decode_header(msg.get("Subject", "(no subject)"))

    lines = [f"# {subject}", ""]
    lines.append(f"**From:** {from_}  ")
    lines.append(f"**To:** {to}  ")
    if cc:
        lines.append(f"**Cc:** {cc}  ")
    lines.append(f"**Date:** {date}  ")
    lines.append("")

    attachments = get_attachments(msg)
    if attachments:
        lines.append("**Attachments:**  ")
        for filename, data in attachments:
            if extract_dir:
                extract_dir.mkdir(parents=True, exist_ok=True)
                out = extract_dir / filename
                out.write_bytes(data)
                lines.append(f"- [{filename}](<{out}>)  ")
                print(f"Extracted: {out}", file=sys.stderr)
            else:
                lines.append(f"- {filename} ({len(data):,} bytes)  ")
        lines.append("")

    lines.append("---")
    lines.append("")
    lines.append(extract_body(msg))

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Convert EML to Markdown")
    parser.add_argument("file", help="Path to the .eml file")
    parser.add_argument("--save", metavar="DIR", nargs="?", const="",
                        help="Save .md output to DIR (default: same dir as EML)")
    parser.add_argument("--extract-attachments", metavar="DIR", nargs="?", const="",
                        help="Extract attachments to DIR (default: <eml-name>-attachments/)")
    args = parser.parse_args()

    path = Path(args.file)
    if not path.exists():
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    extract_dir = None
    if args.extract_attachments is not None:
        extract_dir = Path(args.extract_attachments) if args.extract_attachments \
            else path.parent / (path.stem + "-attachments")

    md = eml_to_markdown(path, extract_dir=extract_dir)

    if args.save is not None:
        out_dir = Path(args.save) if args.save else path.parent
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / path.with_suffix(".md").name
        out_path.write_text(md, encoding="utf-8")
        print(f"Saved: {out_path}", file=sys.stderr)
    else:
        print(md)


if __name__ == "__main__":
    main()
