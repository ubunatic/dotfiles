#!/usr/bin/env python3
"""Decode or clean <data> fields in a macOS plist file.

Usage:
  decode.py [--clean] <file.plist> [keep_key ...]

  --clean   Strip all keys not listed as keep_keys and rewrite the file.
            If no keep_keys are given, uses the built-in KEEP set.
"""

import sys
import plistlib
import base64
import xml.etree.ElementTree as ET

# Default keys to retain when --clean is used
KEEP = {
    "appearanceSize", "appearanceStyle", "menubarIcon",
    "preferencesVersion", "previewFocusedWindow",
    "settingsWindowShownOnFirstLaunch", "shortcutCount", "updatePolicy",
}


def try_decode_bplist(raw: bytes, key: str) -> None:
    if raw[:8] == b"bplist00":
        try:
            inner = plistlib.loads(raw)
            print(f"  -> decoded as bplist: {inner}")
            return
        except Exception as e:
            print(f"  -> bplist parse failed: {e}")

    # Try to find readable strings in the blob
    strings = [
        s for s in raw.decode("latin-1").split("\x00")
        if len(s) > 3 and s.isprintable()
    ]
    if strings:
        print(f"  -> readable strings: {strings}")
    else:
        print(f"  -> raw bytes ({len(raw)} bytes): {raw[:64].hex()}...")


def decode_plist(path: str) -> None:
    tree = ET.parse(path)
    root = tree.getroot()
    body = root.find("dict")
    if body is None:
        print("No top-level <dict> found.")
        return

    children = list(body)
    i = 0
    while i < len(children):
        child = children[i]
        if child.tag == "key":
            key = child.text or ""
            i += 1
            if i < len(children) and children[i].tag == "data":
                raw_b64 = (children[i].text or "").replace("\n", "").replace("\t", "").strip()
                raw = base64.b64decode(raw_b64)
                print(f"\n[{key}]")
                try_decode_bplist(raw, key)
        i += 1




def clean_plist(path: str, keep: set) -> None:
    with open(path, "rb") as f:
        data = plistlib.load(f)
    removed = sorted(k for k in data if k not in keep)
    filtered = {k: v for k, v in data.items() if k in keep}
    with open(path, "wb") as f:
        plistlib.dump(filtered, f, fmt=plistlib.FMT_XML, sort_keys=True)
    print(f"Kept    ({len(filtered)}): {sorted(filtered.keys())}")
    print(f"Removed ({len(removed)}): {removed}")


if __name__ == "__main__":
    args = sys.argv[1:]
    clean_mode = "--clean" in args
    if clean_mode:
        args.remove("--clean")

    path = args[0] if args else "com.lwouis.alt-tab-macos.plist"
    keep = set(args[1:]) if len(args) > 1 else KEEP

    if clean_mode:
        clean_plist(path, keep)
    else:
        decode_plist(path)
