#!/usr/bin/env python3
"""
Vision/OCR via local MLX (Apple Silicon optimized).

Uses mlx_vlm for fast inference on Apple Silicon.
Wide images (aspect ratio > 1.5) are automatically split into left/right
halves and processed separately to avoid Metal OOM errors.

Usage:
    python3 mlx-vision.py <image.jpg> [<image2.png> ...]
    python3 mlx-vision.py <image.jpg> --mode accounting
    python3 mlx-vision.py <image.jpg> --model mlx-community/Qwen2.5-VL-7B-Instruct-4bit
"""

import argparse
import sys
import tempfile
from pathlib import Path

DEFAULT_MODEL = "mlx-community/Qwen2.5-VL-7B-Instruct-4bit"

# Aspect ratio above which an image is split left/right before OCR
SPLIT_ASPECT_RATIO = 1.5

DEFAULT_PROMPT = (
    "Extract and transcribe all text visible in this image. "
    "Preserve the layout and formatting as much as possible. "
    "If there are multiple sections, clearly separate them. "
    "Do not skip any region of the image — scan the full width and height including headers, footers, sidebars, and small print."
)

ACCOUNTING_PROMPT = (
    "You are an accounting document scanner. Extract ALL data from this document section. "
    "Scan the ENTIRE image including all corners and edges. "
    "Do not stop early — every field matters.\n\n"
    "For each field, append a confidence indicator in brackets: [HIGH], [MEDIUM], or [LOW].\n"
    "- HIGH: text is clearly printed/typed and unambiguous\n"
    "- MEDIUM: text is handwritten, partially obscured, or could be misread\n"
    "- LOW: text is unclear, damaged, very small, or you are guessing\n\n"
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
    "Example: '- **IBAN:** DE 03 5001 0517 5415 0692 76 [HIGH]'\n"
    "If a field is not present, write 'n/a'. Do not omit fields."
)

MODES = {
    "ocr": (DEFAULT_MODEL, DEFAULT_PROMPT),
    "accounting": (DEFAULT_MODEL, ACCOUNTING_PROMPT),
}


def split_image(image_path: str) -> list[str]:
    """
    Split a wide image into left and right halves.
    Returns a list of temp file paths. Caller must clean them up.
    """
    try:
        from PIL import Image
    except ImportError:
        raise ImportError("Pillow is required for image splitting: pip install Pillow")

    img = Image.open(image_path)
    w, h = img.size
    overlap = w // 10  # 10% overlap so no characters are cut at the split boundary

    left = img.crop((0, 0, w // 2 + overlap, h))
    right = img.crop((w // 2 - overlap, 0, w, h))

    suffix = Path(image_path).suffix or ".png"
    tmp_left = tempfile.NamedTemporaryFile(suffix=f"-left{suffix}", delete=False)
    tmp_right = tempfile.NamedTemporaryFile(suffix=f"-right{suffix}", delete=False)

    left.save(tmp_left.name)
    right.save(tmp_right.name)

    return [tmp_left.name, tmp_right.name]


def is_wide(image_path: str) -> bool:
    """Return True if the image aspect ratio exceeds SPLIT_ASPECT_RATIO."""
    try:
        from PIL import Image
        img = Image.open(image_path)
        w, h = img.size
        return (w / h) > SPLIT_ASPECT_RATIO
    except Exception:
        return False


def call_mlx(model_obj, processor, prompt: str, image_path: str) -> str:
    """Run inference on a single image with an already-loaded model."""
    try:
        from mlx_vlm import generate
        from mlx_vlm.prompt_utils import apply_chat_template
    except ImportError:
        raise ImportError("mlx_vlm is not installed. Install it with: pip install mlx-vlm")

    config = model_obj.config
    formatted_prompt = apply_chat_template(processor, config, prompt, num_images=1)
    result = generate(model_obj, processor, formatted_prompt, image=[image_path], max_tokens=2048, verbose=False)
    return result.text.strip() if hasattr(result, "text") else str(result).strip()


def process_image(image_path: str, model: str, prompt: str, label: bool = False) -> None:
    """Process a single image, splitting wide images automatically."""
    try:
        from mlx_vlm.generate import load
    except ImportError:
        print("mlx_vlm is not installed. Install it with: pip install mlx-vlm", file=sys.stderr)
        sys.exit(1)

    if label:
        print(f"\n{'='*60}\nFile: {image_path}\nModel: {model}\n{'='*60}\n")

    try:
        model_obj, processor = load(model)
    except Exception as e:
        print(f"Error loading model {model}: {e}", file=sys.stderr)
        sys.exit(1)

    temp_files = []
    try:
        if is_wide(image_path):
            print(f"[wide image — splitting left/right]", file=sys.stderr)
            halves = split_image(image_path)
            temp_files = halves
            parts = []
            for i, half_path in enumerate(halves):
                side = "left" if i == 0 else "right"
                print(f"[scanning {side} half]", file=sys.stderr)
                result = call_mlx(model_obj, processor, prompt, half_path)
                parts.append(f"## {side.capitalize()} half\n\n{result}")
            print("\n\n".join(parts))
        else:
            result = call_mlx(model_obj, processor, prompt, image_path)
            print(result)
    except Exception as e:
        print(f"Error processing {image_path}: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        for f in temp_files:
            Path(f).unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(
        description="Vision/OCR via local MLX (Apple Silicon optimized)",
        epilog="Example: mlx-vision.py invoice.png --mode accounting",
    )
    parser.add_argument("images", nargs="+", help="One or more image file paths")
    parser.add_argument(
        "--mode",
        choices=list(MODES.keys()),
        default=None,
        help="Preset mode: 'ocr' (default) or 'accounting' (full accounting prompt)",
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

    mode_model, mode_prompt = MODES[args.mode] if args.mode else (DEFAULT_MODEL, DEFAULT_PROMPT)
    model = args.model or mode_model
    prompt = args.prompt or mode_prompt
    label = len(args.images) > 1

    for image_path in args.images:
        process_image(image_path, model, prompt, label=label)


if __name__ == "__main__":
    main()
