# People Folder

> **AI agents:** This README documents structure and conventions only. Do not add names,
> personal details, or other instance-specific content here — keep it generic and reusable.
> Instance-specific team content belongs in [Team.md](Team.md).

This folder tracks relationships and people-management work: 1:1s, personal profiles,
team context, hiring, and reviews.

## AI Agent Context

For team roster, name spellings, and communication style, see [Team.md](Team.md).

For detailed communication style per person, check `About/<Name>.md`.
If no profile exists yet, ask before drafting.

## Folder Structure

```
People/
  README.md               ← this file
  Team.md                 ← team roster, name spellings, communication style
  UserProfile.md          ← repo owner's working style (short; links to About/)
  Onboarding.md           ← onboarding checklist / guide

  About/
    TEMPLATE.md           ← profile template with guiding questions
    About <Name>.md       ← one file per person; filled in over 1:1s

  1on1s/
    1on1s.md              ← central hub: cadence table + per-person standing topics
    <Name>.md             ← rolling notes file per person (next 1:1 + past 1:1s)
    archive/              ← completed meeting notes (date-prefixed)

  EngEn/
    EngEn Team.md         ← team vision, structure, owned domains
    EngEn Skills.md       ← skills landscape for the team
    skills.csv            ← structured skills data

  Hiring/                 ← interview notes, candidate tracking, ref material

  Reviews/
    YYYY-MM <Name> …      ← one file per review cycle per person
```

## Core Patterns

### One file per person, two roles
Each person has:
- `About/<Name>.md` — who they are, how they work, how to collaborate with them
- `1on1s/<Name>.md` — rolling meeting notes (next agenda + past sessions, newest first)

Both files cross-link to each other.

### Profiles (About/)
Use `TEMPLATE.md` as the starting point. Fill in sections incrementally from 1:1
conversations, not all at once. The front matter in each file lists the source files
that fed into it (team roster, 1:1 notes), so context is traceable.

### 1:1 Hub (1on1s.md)
`1on1s.md` is the manager's reference for *all* 1:1s:
- A cadence table (who, how often, why)
- Per-person standing topics and recurring questions

Individual `<Name>.md` files hold the actual session notes. Keep one "Next 1:1" section
at the top; after the meeting, move it to "Previous 1:1s" with a dated archive link.

### Archive
When a 1:1 note is finalised, move it to `archive/YYYY-MM-DD <Name> - <context>.md`
and leave a link in `<Name>.md` under "Previous 1:1s".

### Reviews (Reviews/)
One file per review cycle, named `YYYY-MM <Name> <context>.md`
(e.g., `2026-02 Self Review.md`). Keep drafts here until submitted.

## Starting Fresh

1. Populate [Team.md](Team.md) with your team roster and name spellings.
2. Copy `About/TEMPLATE.md` → `About/About <Name>.md` for each person.
3. Create `1on1s/<Name>.md` with a "Next 1:1" section.
4. Add the person to the cadence table in `1on1s/1on1s.md`.
5. Fill in `About/<Name>.md` gradually — treat every 1:1 as an opportunity to add a note.
