#!/usr/bin/env python3
"""
Convert PDF pages to PNG images for vision models.

Generates one PNG per page, named <basename>-page-<N>.png
Output files are saved next to the source PDF.

Uses pdftoppm from poppler to convert PDFs.

Usage:
    python3 pdf2img.py <input.pdf>
    python3 pdf2img.py <input.pdf> <input2.pdf> ...
"""

import argparse
import glob
import shutil
import subprocess
import sys
from pathlib import Path


def pdf_to_images(pdf_path: str) -> list[str]:
    """
    Convert all pages of a PDF to PNG images using pdftoppm.

    Returns a list of output file paths (one per page).
    Raises FileNotFoundError or RuntimeError on failure.
    """
    # Check if pdftoppm is available
    if not shutil.which("pdftoppm"):
        raise RuntimeError(
            "pdftoppm not found. Install poppler: brew install poppler"
        )

    pdf_file = Path(pdf_path)

    if not pdf_file.exists():
        raise FileNotFoundError(f"PDF file not found: {pdf_path}")

    if not pdf_file.suffix.lower() == ".pdf":
        raise ValueError(f"File does not have .pdf extension: {pdf_path}")

    basename = pdf_file.stem  # filename without extension
    output_dir = pdf_file.parent
    output_prefix = output_dir / f"{basename}-page"

    try:
        subprocess.run(
            ["pdftoppm", "-r", "300", "-png", str(pdf_file), str(output_prefix)],
            check=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to convert PDF {pdf_path}: {e.stderr.decode()}")

    # Glob for generated files: <prefix>-<N>.png
    pattern = f"{output_prefix}-*.png"
    output_files = sorted(glob.glob(pattern))

    if not output_files:
        raise RuntimeError(f"No PNG files were generated from {pdf_path}")

    return output_files


def main():
    parser = argparse.ArgumentParser(
        description="Convert PDF pages to PNG images for vision models",
        epilog="Example: pdf2img.py document.pdf",
    )
    parser.add_argument(
        "pdfs",
        nargs="+",
        help="One or more PDF file paths",
    )

    args = parser.parse_args()

    all_output_files = []

    for pdf_path in args.pdfs:
        try:
            output_files = pdf_to_images(pdf_path)
            all_output_files.extend(output_files)
            for output_file in output_files:
                print(output_file)
        except (FileNotFoundError, ValueError, RuntimeError) as e:
            print(f"Error processing {pdf_path}: {e}", file=sys.stderr)
            sys.exit(1)

    # Print summary
    if all_output_files:
        print(f"\n# Converted {len(all_output_files)} page(s) total", file=sys.stderr)


if __name__ == "__main__":
    main()
