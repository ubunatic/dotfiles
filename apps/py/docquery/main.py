#!/usr/bin/env python3

import argparse
import bs4
import sys

def css_select(text, sel, inner_text=False):
    soup = bs4.BeautifulSoup(text, 'html.parser')
    elements = soup.select(sel)
    if inner_text:
        return ''.join(element.get_text() for element in elements)
    return ''.join(str(element) for element in elements)

def css_doc_select(doc, sel, inner_text=False):
    if doc == "-":
        doc = sys.stdin.name

    with open(doc, "r") as f: text = f.read()
    return css_select(text, sel, inner_text=inner_text)

def run():
    argp = argparse.ArgumentParser(
        description="DocQuery - A tool for querying documents",
    )
    argp.add_argument(
        "document",
        type=str,
        default="-",
        help="The document to query",
    )
    argp.add_argument(
        "-s",
        "--selector",
        type=str,
        default="*",
        help="CSS selector to filter elements",
    )
    argp.add_argument(
        "-i",
        "--inner-text",
        action="store_true",
        help="Return only the inner text of the selected elements",
    )

    args = argp.parse_args()
    doc:str = args.document
    sel:str = args.selector
    print(css_doc_select(doc, sel, inner_text=args.inner_text))

if __name__ == "__main__": run()
