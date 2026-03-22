# Document to Markdown Conversion

Convert PDFs, Word documents, and other formats to clean, AI-enhanced markdown.

## Quick Start

```bash
make doc FILE=path/to/document.pdf
```

This will:
1. Extract raw text from the document
2. Send it to Claude API for cleanup and formatting
3. Save the result as `document.md` alongside the original

## Supported Formats

- **PDF** (.pdf) — extracted via `pdftotext` or `pdfplumber`
- **Word** (.docx, .doc) — extracted via `pandoc` or `python-docx`
- **OpenDocument** (.odt) — extracted via `pandoc`
- **Plain text** (.txt, .md) — read as-is
- **Other formats** (.rtf, etc.) — via `pandoc` if available

## Usage

### Basic conversion (save to .md file)

```bash
make doc FILE=invoice.pdf
make doc FILE=contract.docx
make doc FILE=notes.txt
```

Output file will be created at `invoice.md`, `contract.md`, `notes.md`, etc.

### Print to stdout instead of saving

```bash
python3 .code/scripts/doc2md.py document.pdf --no-save
```

### Specify custom output path

```bash
python3 .code/scripts/doc2md.py document.pdf --output cleaned.md
```

## How It Works

### Text Extraction

The script detects the file format and extracts raw text:

- **PDF**: Uses `pdftotext -layout` for structured extraction, with fallback to `pdfplumber` Python library
- **DOCX**: Uses `pandoc` for compatibility, with fallback to `python-docx`
- **Plain text**: Reads directly

### Claude API Cleanup

The extracted text is sent to Claude Haiku with a cleanup prompt that:

1. **Removes hyphenation artifacts** — `Vereins-\nvorsitzender` → `Vereinsvorsitzender`
2. **Fixes line breaks** — Restores paragraphs broken across columns or pages
3. **Normalizes whitespace** — Removes extra spaces, aligns indentation
4. **Fixes OCR typos** — Common extraction errors where detectable
5. **Structures as markdown** — Proper headings, lists, paragraphs
6. **Preserves language** — Does NOT translate (keeps original language)
7. **Removes cruft** — Strips headers, footers, page numbers, artifacts
8. **Preserves meaning** — Keeps all meaningful content and original structure

## Requirements

### Environment

Set your Claude API key:

```bash
export ANTHROPIC_API_KEY=your-key-here
```

The script uses `claude-haiku-4-5-20251001` (cost-effective for large documents).

### Dependencies

Required for basic operation:
- Python 3.7+
- `curl` and `urllib` (standard library, no install needed)

Optional (for specific formats):

**PDF extraction** — pick one:
```bash
brew install poppler          # for pdftotext
pip3 install pdfplumber       # Python fallback
```

**DOCX extraction** — pick one:
```bash
brew install pandoc           # universal format converter
pip3 install python-docx      # Python native support
```

## Examples

### Convert a scanned invoice

```bash
make doc FILE=invoice_scan.pdf
# → invoice_scan.md (clean, structured markdown)
```

### Clean up exported Word document

```bash
make doc FILE=report.docx
# → report.md (proper markdown formatting)
```

### Batch convert multiple files

```bash
for file in *.pdf; do
  make doc FILE="$file"
done
```

## Limitations

- Maximum document size depends on Claude API token limits (default model handles ~2M tokens)
- Complex layouts (multi-column, tables) may need manual post-processing
- Images in documents are not extracted or processed
- Encrypted/password-protected PDFs will fail

## Troubleshooting

### "Could not extract PDF text"

Install extraction tools:
```bash
# Option 1: poppler (faster)
brew install poppler

# Option 2: pdfplumber (Python)
pip3 install pdfplumber
```

### "Could not extract DOCX text"

Install conversion tools:
```bash
# Option 1: pandoc (universal)
brew install pandoc

# Option 2: python-docx
pip3 install python-docx
```

### "ANTHROPIC_API_KEY not set"

Export your API key:
```bash
export ANTHROPIC_API_KEY=sk-...
```

Add to your shell profile to persist across sessions.

### Document is too long / timeout

If Claude takes too long, try:
- Split the document manually into smaller pieces
- Use `--no-save` to debug output first
- Check API status: `curl https://api.anthropic.com/health`

## Implementation Details

**Script location:** `.code/scripts/doc2md.py`

**Makefile target:**
```makefile
doc: ⚙️  ## convert document to markdown (FILE=...; supports PDF, DOCX, TXT, etc.)
	@test -n "$(FILE)" || (echo "Usage: make doc FILE=<path>" && exit 1)
	python3 .code/scripts/doc2md.py "$(FILE)"
```

**Cleanup prompt:** Removes formatting artifacts while preserving language and meaning.

## See Also

- [Vision/OCR for images](DocsRepo.md) — `make vision IMG=...` for image OCR
- [EML to Markdown](DocsRepo.md) — `make eml FILE=...` for email conversion
- [Guides/Style Guide](<Style Guide.md>) — markdown formatting conventions used throughout the repo
