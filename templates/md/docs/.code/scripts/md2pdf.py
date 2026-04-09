import markdown
import pdfkit
import os
import sys

def convert_md_to_pdf(input_md_path, output_pdf_path):
    # 1. Verify file exists
    if not os.path.exists(input_md_path):
        print(f"Error: The file {input_md_path} does not exist.")
        sys.exit(1)

    # 2. Read the Markdown file
    with open(input_md_path, 'r', encoding='utf-8') as f:
        md_text = f.read()

    # 3. Convert Markdown to HTML
    # The 'extra' extension enables standard features like tables and fenced code blocks
    html_content = markdown.markdown(md_text, extensions=['extra'])

    # 4. Resolve local paths and inject basic styling
    # This is the crucial step for embedding local images
    base_dir = os.path.abspath(os.path.dirname(input_md_path))

    html_template = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <base href="file://{base_dir}/">
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; padding: 2em; max-width: 800px; margin: 0 auto; }}
            img {{ max-width: 100%; height: auto; display: block; margin: 1em 0; }}
            code {{ background: #f4f4f4; padding: 2px 5px; border-radius: 3px; font-family: monospace; }}
            pre {{ background: #f4f4f4; padding: 1em; overflow-x: auto; border-radius: 5px; }}
            blockquote {{ border-left: 4px solid #ccc; margin: 0; padding-left: 1em; color: #666; }}
            table {{ border-collapse: collapse; width: 100%; margin-bottom: 1em; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
            th {{ background-color: #f2f2f2; }}
        </style>
    </head>
    <body>
        {html_content}
    </body>
    </html>
    """

    # 5. Configure PDF options to allow local file access
    options = {
        'enable-local-file-access': None,
        'encoding': "UTF-8",
        'margin-top': '20mm',
        'margin-right': '20mm',
        'margin-bottom': '20mm',
        'margin-left': '20mm',
    }

    # 6. Generate the PDF
    try:
        print(f"Rendering PDF... (Make sure wkhtmltopdf is installed on your system)")
        pdfkit.from_string(html_template, output_pdf_path, options=options)
        print(f"Success! PDF saved to: {output_pdf_path}")
    except Exception as e:
        print(f"An error occurred during PDF generation: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python md2pdf.py <input.md> <output.pdf>")
    else:
        convert_md_to_pdf(sys.argv[1], sys.argv[2])