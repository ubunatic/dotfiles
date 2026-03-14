#!/usr/bin/env python3
"""Convert a .ucdata file (raw UCKeyboardLayout binary) to .keylayout XML.

Usage:
  python3 extract_layout.py <layout.ucdata> [output.keylayout]

  layout.ucdata:  raw binary extracted by the Swift extract_layout tool
  output:         output file path (default: <input-stem>.keylayout)

Example:
  python3 extract_layout.py "German_–_Standard.ucdata"
  python3 extract_layout.py "German_–_Standard.ucdata" german-standard.keylayout
"""

import sys
import struct
from pathlib import Path

# ---------------------------------------------------------------------------
# Parse UCKeyboardLayout binary
# UCKeyboardLayout binary format (big-endian):
#   uint16 keyLayoutHeaderFormat
#   uint16 keyLayoutDataVersion
#   uint32 keyLayoutFeatureInfoOffset  (0 if absent)
#   uint32 keyboardTypeCount
#   [keyboardTypeList]: keyboardTypeCount * 24 bytes
#     uint32 lastKeyboardType
#     uint32 keyModifiersToTableNumOffset
#     uint32 keyToCharTableIndexOffset
#     uint32 keyStateRecordsIndexOffset
#     uint32 keyStateTerminatorsOffset
#     uint32 keySequenceDataIndexOffset
# ---------------------------------------------------------------------------

def parse_uchr(data: bytes) -> dict:
    """Parse UCKeyboardLayout binary. Returns a dict with modifier tables and char tables."""
    be = "<"  # UCKeyboardLayout is stored in host byte order (little-endian on modern Macs)
    offset = 0

    fmt, ver, feat_off, kb_type_count = struct.unpack_from(f"{be}HHII", data, offset)
    offset += 12

    print(f"  format={fmt} version={ver} keyboardTypeCount={kb_type_count}")

    # Each entry: firstKeyboardType(4) + lastKeyboardType(4) + 5 offsets(4 each) = 28 bytes
    entries = []
    for _ in range(kb_type_count):
        first_kb, last_kb, mod_off, ktc_off, ksr_off, kst_off, ksd_off = struct.unpack_from(f"{be}IIIIIII", data, offset)
        entries.append((first_kb, last_kb, mod_off, ktc_off, ksr_off, kst_off, ksd_off))
        offset += 28

    # Use the first entry (covers most physical keyboards)
    first_kb, last_kb, mod_off, ktc_off, ksr_off, kst_off, ksd_off = entries[0]

    # Parse UCKeyModifiersToTableNum
    # uint16 format, uint16 defaultTableNum, uint32 modifiersCount, uint8 tableNum[modifiersCount]
    _fmt_m, def_table, mod_count = struct.unpack_from(f"{be}HHI", data, mod_off)
    mod_map = list(struct.unpack_from(f"{mod_count}B", data, mod_off + 8))

    # Parse UCKeyToCharTableIndex
    # uint16 format, uint16 keyToCharTableSize, uint32 keyToCharTableCount, uint32 offsets[count]
    _fmt_t, tbl_size, tbl_count = struct.unpack_from(f"{be}HHI", data, ktc_off)
    tbl_offsets = list(struct.unpack_from(f"{be}{tbl_count}I", data, ktc_off + 8))

    # For each table, read keyToCharTableSize uint16 entries (UCKeyOutput is UInt16)
    tables = []
    for toff in tbl_offsets:
        entries_raw = struct.unpack_from(f"{be}{tbl_size}H", data, toff)
        tables.append(list(entries_raw))

    return {
        "default_table": def_table,
        "mod_count": mod_count,
        "mod_map": mod_map,
        "tbl_size": tbl_size,
        "tbl_count": tbl_count,
        "tables": tables,
    }

# ---------------------------------------------------------------------------
# Render as .keylayout XML
# ---------------------------------------------------------------------------

MODIFIER_NAMES = {
    0x000: "",
    0x002: "anyShift",
    0x004: "anyOption",
    0x006: "anyShift anyOption",
    0x008: "anyControl",
    0x00A: "anyShift anyControl",
    0x00C: "anyOption anyControl",
    0x00E: "anyShift anyOption anyControl",
    0x020: "caps",
}

def uchr_char(val: int) -> str | None:
    """Convert a UCKeyOutput value to a character or None."""
    if val & 0x4000:
        return None  # dead key sequence (bit 14 in UCKeyOutput uint16)
    if val == 0xFFFE or val == 0xFFFF or val == 0:
        return None
    try:
        ch = chr(val & 0x3FFF)
        if ch.isprintable() and ch != " ":
            return ch
        if val == 0x0020:
            return " "
        return None
    except (ValueError, OverflowError):
        return None

def xml_char(ch: str) -> str:
    return (ch.replace("&", "&amp;")
              .replace("<", "&lt;")
              .replace(">", "&gt;")
              .replace('"', "&quot;"))

def render_keylayout(name: str, parsed: dict) -> str:
    tables = parsed["tables"]
    mod_map = parsed["mod_map"]

    lines = []
    lines.append('<?xml version="1.1" encoding="UTF-8"?>')
    lines.append('<!DOCTYPE keyboard SYSTEM "file://localhost/System/Library/DTDs/KeyboardLayout.dtd">')
    lines.append(f'<keyboard group="0" id="-1" name="{xml_char(name)}" maxout="1">')
    lines.append('  <layouts>')
    lines.append('    <layout first="0" last="207" mapSet="0" modifiers="m"/>')
    lines.append('  </layouts>')

    # Collect unique modifier_bits → table_index groups
    seen: dict[int, list[int]] = {}
    for mod_bits, tbl_idx in enumerate(mod_map):
        seen.setdefault(tbl_idx, []).append(mod_bits)

    lines.append('  <modifierMap id="m" defaultIndex="0">')
    for tbl_idx in sorted(seen):
        lines.append(f'    <keyMapSelect mapIndex="{tbl_idx}">')
        for mod_bits in seen[tbl_idx]:
            mod_name = MODIFIER_NAMES.get(mod_bits, f"<!-- bits={mod_bits:#04x} -->")
            lines.append(f'      <modifier keys="{mod_name}"/>')
        lines.append('    </keyMapSelect>')
    lines.append('  </modifierMap>')

    lines.append('  <keyMapSet id="0">')
    for ti, table in enumerate(tables):
        lines.append(f'    <keyMap index="{ti}">')
        for key_code, val in enumerate(table):
            ch = uchr_char(val)
            if ch is not None:
                lines.append(f'      <key code="{key_code}" output="{xml_char(ch)}"/>')
        lines.append('    </keyMap>')
    lines.append('  </keyMapSet>')
    lines.append('</keyboard>')
    return "\n".join(lines)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    in_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else in_path.with_suffix(".keylayout")
    name = in_path.stem.replace("_", " ")

    raw = in_path.read_bytes()
    print(f"Parsing {in_path} ({len(raw)} bytes)...")
    parsed = parse_uchr(raw)
    xml = render_keylayout(name, parsed)

    out_path.write_text(xml, encoding="utf-8")
    print(f"Written to: {out_path}")
