# German-PC.keylayout — Fix Plan

## Bug 1: Dead circumflex (state 1) is unreachable

Action `id="0"` (→ state 1) is defined but no key triggers it — key 10 was fixed to output `^` directly.

**Decision needed:** pick one:
- **A)** Re-enable dead `^` on key 10 (move `<` permanently to key 50, `>` on Shift+50)
- **B)** Remove action 0 and all state 1 `<when>` entries from actions 6–15 — circumflex dead key gone

## Bug 2: Tilde state (5) incomplete for e, i, u

Actions 7/8/10/12/13/15 are missing a `<when state="5" .../>` entry.
Add these six lines in the `<actions>` section:

| Action | Key | Add |
|--------|-----|-----|
| 7  | e | `<when state="5" output="ẽ"/>` |
| 8  | i | `<when state="5" output="ĩ"/>` |
| 10 | u | `<when state="5" output="ũ"/>` |
| 12 | E | `<when state="5" output="Ẽ"/>` |
| 13 | I | `<when state="5" output="Ĩ"/>` |
| 15 | U | `<when state="5" output="Ũ"/>` |

## Minor: Caps Lock key 10 inconsistency

- Shift+key10 → `°` (degree)
- Caps+key10 → `^` (same as unshifted)

Fix keyMap index 2, key code 10: change output to `°` to match Shift.

## Cleanup: remove commented-out alternatives

Lines 80–128 and similar blocks have leftover `<!-- ... -->` alternative mappings
for key 10 and key 50. Once Bug 1 is decided, delete the losers.
