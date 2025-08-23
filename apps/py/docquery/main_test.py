import pytest

from main import css_doc_select, css_select
from dataclasses import dataclass
import tempfile

@dataclass
class TextCase:
    input: str
    sel: str
    inner_text: bool
    expected: str

def test_run_basic():
    # Mock input data
    tests = [
        TextCase(
            input="<html><body><div class='test'>Hello World</div></body></html>",
            sel=".test",
            inner_text=True,
            expected="Hello World"
        ),
        TextCase(
            input="<html><body><div class='test'>Hello <b>World</b></div></body></html>",
            sel=".test b",
            inner_text=False,
            expected="<b>World</b>"
        ),
        TextCase(
            input="<html><body><div class='test'>Hello <b>World</b></div></body></html>",
            sel=".other",
            inner_text=False,
            expected=""  # No match, should return empty string
        ),
    ]
    for test in tests:
        res = css_select(test.input, test.sel, inner_text=test.inner_text)
        assert res == test.expected, f"Expected '{test.expected}' but got '{res}'"

def test_file_read():
    # create tmp file
    with tempfile.NamedTemporaryFile(delete=False, mode='w+', suffix='.html') as f:
        f.write("<html><body><div class='test'>Hello World</div></body></html>")
        f.seek(0)
        res = css_doc_select(f.name, ".test", inner_text=True)
        assert res == "Hello World", f"Expected 'Hello World' but got '{res}'"

def test_stdin_select(monkeypatch):
    # Mock stdin input
    with tempfile.NamedTemporaryFile(delete=False, mode='w+', suffix='.html') as f:
        f.write("<html><body><div class='test'>Hello World</div></body></html>")
        f.seek(0)
        # Set sys.stdin to read from the temporary file
        monkeypatch.setattr('sys.stdin', f)

        res = css_doc_select("-", ".test", inner_text=True)
        assert res == "Hello World", f"Expected 'Hello World' but got '{res}'"
