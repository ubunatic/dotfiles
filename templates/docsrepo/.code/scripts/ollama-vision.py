#!/usr/bin/env python3
"""
Vision/OCR via local Ollama API.

Uses the Ollama /api/generate endpoint with a vision model to process images.

Usage:
    python3 ollama-vision.py <image.jpg> [<image2.png> ...]
    python3 ollama-vision.py <image.jpg> --model llama3.2-vision --prompt "Describe..."
"""

import argparse
import base64
import json
import sys
import urllib.request
import urllib.error
from pathlib import Path


DEFAULT_MODEL = "llama3.2-vision:latest"
ACCOUNTING_MODEL = "qwen2.5vl:72b"

DEFAULT_PROMPT = (
    "Extract and transcribe all text visible in this image. "
    "Preserve the layout and formatting as much as possible. "
    "If there are multiple sections, clearly separate them. "
    "Do not skip any region of the image — scan the full width and height including headers, footers, sidebars, and small print."
)

ACCOUNTING_PROMPT = (
    "You are an accounting document scanner. Extract ALL data from this document. "
    "Scan the ENTIRE image including left, right, top, bottom, and any side columns. "
    "Do not stop early — every field matters.\n\n"
    "Extract and return in structured markdown:\n"
    "- Vendor / issuer name and address\n"
    "- Document date and document/invoice number\n"
    "- All line items: description, quantity, unit price, total\n"
    "- Subtotal, tax rate, tax amount, grand total\n"
    "- Payment details: IBAN, BIC, bank name, account holder\n"
    "- SEPA mandate reference and type (one-off / recurring)\n"
    "- Any due date or payment terms\n"
    "- Membership or contract fields: name, address, email, fee, start date, signature\n"
    "- Any other amounts or reference numbers visible anywhere in the document\n\n"
    "If a field is not present, write 'n/a'. Do not omit fields."
)

OLLAMA_API = "http://localhost:11434/api/generate"

MODES = {
    "ocr": (DEFAULT_MODEL, DEFAULT_PROMPT),
    "accounting": (ACCOUNTING_MODEL, ACCOUNTING_PROMPT),
}


def encode_image_to_base64(image_path: str) -> str:
    """Read image file and return base64-encoded content."""
    try:
        with open(image_path, "rb") as f:
            return base64.b64encode(f.read()).decode("utf-8")
    except FileNotFoundError:
        raise FileNotFoundError(f"Image file not found: {image_path}")
    except Exception as e:
        raise RuntimeError(f"Failed to read image {image_path}: {e}")


def call_ollama(model: str, prompt: str, image_b64: str) -> str:
    """POST to Ollama API and return the response text."""
    payload = {
        "model": model,
        "prompt": prompt,
        "images": [image_b64],
        "stream": False,
    }

    data = json.dumps(payload).encode()
    req = urllib.request.Request(OLLAMA_API, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            result = json.loads(resp.read())
            return result.get("response", "").strip()
    except urllib.error.URLError as e:
        raise RuntimeError(f"Could not connect to Ollama at {OLLAMA_API}: {e}. Is Ollama running?")


def process_image(image_path: str, model: str, prompt: str, label: bool = False) -> None:
    """Process a single image and print the result."""
    if label:
        print(f"\n{'='*60}")
        print(f"File: {image_path}")
        print(f"Model: {model}")
        print(f"{'='*60}\n")

    try:
        image_b64 = encode_image_to_base64(image_path)
        result = call_ollama(model, prompt, image_b64)
        print(result)
    except (FileNotFoundError, RuntimeError) as e:
        print(f"Error processing {image_path}: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Vision/OCR via local Ollama API",
        epilog="Example: ollama-vision.py invoice.png --mode accounting",
    )
    parser.add_argument(
        "images",
        nargs="+",
        help="One or more image file paths",
    )
    parser.add_argument(
        "--mode",
        choices=list(MODES.keys()),
        default=None,
        help="Preset mode: 'ocr' (default) or 'accounting' (uses minicpm-v + full accounting prompt)",
    )
    parser.add_argument(
        "--model",
        default=None,
        help=f"Vision model name (overrides --mode; default: {DEFAULT_MODEL})",
    )
    parser.add_argument(
        "--prompt",
        default=None,
        help="Custom prompt (overrides --mode; default: OCR/transcription)",
    )

    args = parser.parse_args()

    # Resolve model and prompt: explicit args > mode preset > defaults
    if args.mode:
        mode_model, mode_prompt = MODES[args.mode]
    else:
        mode_model, mode_prompt = DEFAULT_MODEL, DEFAULT_PROMPT

    model = args.model or mode_model
    prompt = args.prompt or mode_prompt

    # If multiple images, label each output block
    label = len(args.images) > 1

    for image_path in args.images:
        process_image(image_path, model, prompt, label=label)


if __name__ == "__main__":
    main()
