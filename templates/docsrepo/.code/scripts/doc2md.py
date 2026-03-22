#!/usr/bin/env python3
"""
Convert documents (PDF, DOCX, etc.) to clean, AI-enhanced markdown.

Extracts raw text from the input file and passes it to a local Ollama model for cleanup,
or sends it directly to Claude API for verbatim-faithful conversion (recommended for legal docs).

Usage:
    python3 doc2md.py path/to/document.pdf
    python3 doc2md.py path/to/document.pdf --source claude
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import urllib.request
import urllib.error
from pathlib import Path


_PROMPT_FILE = Path(__file__).parent.parent / "prompts" / "doc2md.txt"
CLEANUP_PROMPT = _PROMPT_FILE.read_text(encoding="utf-8").strip()


def extract_text_from_pdf(file_path: str) -> str:
    """Extract text from PDF using pdftotext or fallback methods."""
    try:
        # Try pdftotext first (from poppler-utils)
        result = subprocess.run(
            ["pdftotext", "-layout", file_path, "-"],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode == 0:
            return result.stdout
    except FileNotFoundError:
        pass
    except subprocess.TimeoutExpired:
        raise RuntimeError("PDF extraction timed out")

    # Fallback: try with pdfplumber (Python library)
    try:
        import pdfplumber
        with pdfplumber.open(file_path) as pdf:
            text = "\n\n".join(page.extract_text() or "" for page in pdf.pages)
            return text
    except ImportError:
        pass
    except Exception as e:
        raise RuntimeError(f"Failed to extract PDF with pdfplumber: {e}")

    raise RuntimeError(
        "Could not extract PDF text. Install: 'brew install poppler' or 'pip3 install pdfplumber'"
    )


def extract_text_from_docx(file_path: str) -> str:
    """Extract text from DOCX using pandoc or fallback methods."""
    try:
        # Try pandoc first
        result = subprocess.run(
            ["pandoc", file_path, "-t", "plain"],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode == 0:
            return result.stdout
    except FileNotFoundError:
        pass
    except subprocess.TimeoutExpired:
        raise RuntimeError("DOCX extraction timed out")

    # Fallback: try python-docx
    try:
        from docx import Document
        doc = Document(file_path)
        text = "\n\n".join(para.text for para in doc.paragraphs if para.text.strip())
        return text
    except ImportError:
        pass
    except Exception as e:
        raise RuntimeError(f"Failed to extract DOCX with python-docx: {e}")

    raise RuntimeError(
        "Could not extract DOCX text. Install: 'brew install pandoc' or 'pip3 install python-docx'"
    )


def extract_text_from_file(file_path: str) -> str:
    """Extract text from various document formats."""
    path = Path(file_path)
    suffix = path.suffix.lower()

    if suffix == ".pdf":
        return extract_text_from_pdf(file_path)
    elif suffix == ".docx":
        return extract_text_from_docx(file_path)
    elif suffix in (".doc", ".odt", ".rtf"):
        # Attempt with pandoc for other formats
        try:
            result = subprocess.run(
                ["pandoc", file_path, "-t", "plain"],
                capture_output=True,
                text=True,
                timeout=30
            )
            if result.returncode == 0:
                return result.stdout
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass
        raise RuntimeError(f"Unsupported format: {suffix}. Install pandoc or use PDF/DOCX.")
    elif suffix in (".txt", ".md"):
        return path.read_text(encoding="utf-8", errors="replace")
    else:
        raise RuntimeError(f"Unsupported file format: {suffix}")


OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://127.0.0.1:11434")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "phi4")
CLAUDE_MODEL = os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-6")


def call_claude(file_path: str, raw_text: str | None = None) -> str:
    """Call Claude API to convert a document to markdown.

    For PDFs, sends the file directly (native PDF reading).
    For other formats, sends the pre-extracted raw_text.
    """
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise RuntimeError("ANTHROPIC_API_KEY not set in environment")

    suffix = Path(file_path).suffix.lower()

    if suffix == ".pdf":
        # Send PDF natively — Claude reads it directly, no extraction needed
        pdf_data = base64.standard_b64encode(Path(file_path).read_bytes()).decode("utf-8")
        content = [
            {
                "type": "document",
                "source": {"type": "base64", "media_type": "application/pdf", "data": pdf_data},
            },
            {"type": "text", "text": CLEANUP_PROMPT},
        ]
    else:
        # Non-PDF: send pre-extracted text
        if not raw_text:
            raise RuntimeError("raw_text required for non-PDF files with --source claude")
        content = [{"type": "text", "text": f"{CLEANUP_PROMPT}\n\n---RAW TEXT---\n\n{raw_text}"}]

    payload = {
        "model": CLAUDE_MODEL,
        "max_tokens": 8192,
        "messages": [{"role": "user", "content": content}],
    }

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=data,
        headers={
            "Content-Type": "application/json",
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            result = json.loads(resp.read())
            return result["content"][0].get("text", "").strip()
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"Claude API error ({e.code}): {e.read().decode()}")
    except urllib.error.URLError as e:
        raise RuntimeError(f"Network error calling Claude API: {e}")


def call_ollama(raw_text: str) -> str:
    """Call local Ollama to clean up the extracted text."""
    payload = {
        "model": OLLAMA_MODEL,
        "prompt": f"{CLEANUP_PROMPT}\n\n---RAW TEXT---\n\n{raw_text}",
        "stream": False
    }

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        f"{OLLAMA_HOST}/api/generate",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            result = json.loads(resp.read())
            text = result.get("response", "").strip()
            # Strip ```markdown ... ``` wrapper some models add
            if text.startswith("```"):
                text = text.split("\n", 1)[-1]
                if text.endswith("```"):
                    text = text.rsplit("```", 1)[0]
            return text.strip()
    except urllib.error.URLError as e:
        raise RuntimeError(f"Ollama not reachable at {OLLAMA_HOST}: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert documents to clean markdown",
        epilog="Example: doc2md.py document.pdf"
    )
    parser.add_argument(
        "file",
        help="Path to the document (PDF, DOCX, TXT, etc.)"
    )
    parser.add_argument(
        "--output",
        "-o",
        help="Output markdown file (default: same as input with .md extension)"
    )
    parser.add_argument(
        "--no-save",
        action="store_true",
        help="Print to stdout instead of saving to file"
    )
    parser.add_argument(
        "--source",
        choices=["ollama", "claude"],
        default="ollama",
        help="AI backend to use: 'ollama' (local, default) or 'claude' (API, best for legal/official docs)"
    )

    args = parser.parse_args()

    input_path = Path(args.file)
    if not input_path.exists():
        print(f"Error: file not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    suffix = input_path.suffix.lower()
    is_native_pdf = args.source == "claude" and suffix == ".pdf"

    # Extract text (skipped for Claude + PDF — Claude reads natively)
    raw_text = None
    if not is_native_pdf:
        try:
            print(f"Extracting text from {input_path}...", file=sys.stderr)
            raw_text = extract_text_from_file(str(input_path))
            if not raw_text.strip():
                print("Error: extracted text is empty", file=sys.stderr)
                sys.exit(1)
            print(f"Extracted {len(raw_text)} characters", file=sys.stderr)
        except RuntimeError as e:
            print(f"Error extracting text: {e}", file=sys.stderr)
            sys.exit(1)

    # Call AI backend
    try:
        if args.source == "claude":
            print(f"Converting with Claude ({CLAUDE_MODEL})...", file=sys.stderr)
            cleaned_md = call_claude(str(input_path), raw_text)
        else:
            print(f"Cleaning up with Ollama ({OLLAMA_MODEL})...", file=sys.stderr)
            cleaned_md = call_ollama(raw_text)
    except RuntimeError as e:
        print(f"Error calling {args.source}: {e}", file=sys.stderr)
        sys.exit(1)

    # Output
    if args.no_save:
        print(cleaned_md)
    else:
        output_path = Path(args.output) if args.output else input_path.with_suffix(".md")
        output_path.write_text(cleaned_md, encoding="utf-8")
        print(f"Saved: {output_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
