# Extracting macOS Built-in Keyboard Layouts

## Goal

Extract the **German – Standard** keyboard layout (built into macOS) as a `.keylayout`
XML file, so it can be compared to the custom **German - PC** layout in
`config/Library/Keyboard Layouts/German-PC.keylayout`.

## Background

Apple's built-in layouts (including German Standard) are **not stored as individual
`.keylayout` files**. They live inside a compiled binary bundle:

```
/System/Library/Keyboard Layouts/AppleKeyboardLayouts.bundle/
  Contents/Resources/AppleKeyboardLayouts-L.dat   ← all layouts compiled in here
```

The bundle does contain `.lproj` folders for localized names (`de.lproj`, `en.lproj`, …)
but no XML keylayout files.

Searching that `.dat` for `"German"` reveals three entries:
- `German` (offset 269252) — the Standard layout, locale `de`
- `Swiss German` (offset 345930) — locale `de_CH`
- `German-DIN-2137` (offset 613072) — the DIN 2137 variant

## Extraction Approach: TIS API

The correct way to extract the raw key map data is via Apple's **Text Input Services (TIS)** API:

```c
// Carbon / HIToolbox
CFArrayRef  TISCreateInputSourceList(CFDictionaryRef filter, Boolean includeAllInstalled)
CFTypeRef   TISGetInputSourceProperty(TISInputSourceRef source, CFStringRef key)

// relevant property keys:
kTISPropertyLocalizedName          // → CFString  e.g. "German – Standard"
kTISPropertyInputSourceID          // → CFString  e.g. "com.apple.keylayout.German"
kTISPropertyUnicodeKeyLayoutData   // → CFData    raw UCKeyboardLayout binary
```

The `CFData` returned by `kTISPropertyUnicodeKeyLayoutData` contains the
`UCKeyboardLayout` struct (big-endian), which is the same binary format that
`.keylayout` XML files describe.

### UCKeyboardLayout binary layout

```
uint16  keyLayoutHeaderFormat
uint16  keyLayoutDataVersion
uint32  keyLayoutFeatureInfoOffset
uint32  keyboardTypeCount
[keyboardTypeList]:           // keyboardTypeCount entries × 24 bytes
    uint32  lastKeyboardType
    uint32  keyModifiersToTableNumOffset
    uint32  keyToCharTableIndexOffset
    uint32  keyStateRecordsIndexOffset      (dead keys)
    uint32  keyStateTerminatorsOffset
    uint32  keySequenceDataIndexOffset

UCKeyModifiersToTableNum @ keyModifiersToTableNumOffset:
    uint16  defaultTableNum
    uint16  modifiersCount
    uint8   tableNum[modifiersCount]        // modifier_bits → table index

UCKeyToCharTableIndex @ keyToCharTableIndexOffset:
    uint16  keyToCharTableSize              // number of key codes per table
    uint16  keyToCharTableCount            // number of modifier tables
    uint32  offset[keyToCharTableCount]    // absolute offsets into data

Each table @ offset[i]:
    uint32  entry[keyToCharTableSize]      // key code → UCKeyOutput value

UCKeyOutput value encoding:
    bit 31 set  → dead key sequence state index
    0xFFFE/0xFFFF/0x0000 → no output
    lower 16 bits → Unicode code point
```

## What Failed: Python ctypes

Calling `TISCreateInputSourceList` via `ctypes` causes a **segfault** on macOS 15+
because TIS requires an active Cocoa run loop / autorelease pool. Simply loading
Carbon via `ctypes.cdll` is not sufficient.

`pyobjc-framework-Carbon` was installed in `.venv` but the package only ships a
stub with no TIS bindings (`pkgutil` shows only `_metadata` as a submodule).

## Recommended Next Steps

### Option A — Swift CLI (recommended)

Swift has full access to HIToolbox and can extract the layout in ~30 lines.
Suggested location: `apps/macos/extract_layout/main.swift`

```swift
import Carbon

let sources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
for src in sources {
    let name = TISGetInputSourceProperty(src, kTISPropertyLocalizedName)
        .map { Unmanaged<CFString>.fromOpaque($0).takeUnretainedValue() as String } ?? ""
    guard name.contains("German") else { continue }
    guard let dataPtr = TISGetInputSourceProperty(src, kTISPropertyUnicodeKeyLayoutData) else { continue }
    let data = Unmanaged<CFData>.fromOpaque(dataPtr).takeUnretainedValue() as Data
    // write data to file, then parse UCKeyboardLayout → XML
    try! data.write(to: URL(fileURLWithPath: "\(name).ucdata"))
    print("Saved \(name) (\(data.count) bytes)")
}
```

Then parse the `.ucdata` with the Python UCKeyboardLayout parser already in
`extract_layout.py` (`parse_uchr` + `render_keylayout` are complete).

### Option B — AppleScript + system_profiler

Limited option: `system_profiler SPInputSourceDataType` lists installed input sources
but does not expose key mapping data.

### Option C — Ukulele / open-source layouts

The **German Standard** layout is available as open-source XML, shared by the
Ukulele keyboard editor community. Search for `keylayout German Standard` on
GitHub or the Ukulele forums.

## Files in This Directory

| File | Purpose |
|---|---|
| `extract_layout.py` | Python: list sources, parse UCKeyboardLayout binary, render `.keylayout` XML |
| `decode.py` | Python: decode/inspect/clean `.plist` `<data>` fields |
| `EXTRACT_LAYOUT.md` | This document |
