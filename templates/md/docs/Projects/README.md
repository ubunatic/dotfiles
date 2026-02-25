# Projects Folder

One folder per project or initiative. The README is the entry point — status, context,
and links to everything else.

## Folder Structure

```
Projects/
  <Project Name>/
    README.md     ← status, summary, key decisions, links to sub-docs
    ref/          ← stable reference material: external docs, diagrams, research base
    Reports/      ← dated outputs: research notes, AI analyses, investigation results
    WIP/          ← active working documents: ideas, plans, messages in progress
    Overview/     ← optional; structured overview docs for larger/longer projects
```

Not every project needs every folder. Start with `README.md` + `ref/` and add the rest
as material accumulates.

## File Naming Conventions

**Reports/** — date-prefix every file:
```
YYYY-MM-DD <descriptive title>.md
```

**WIP/** — type-prefix every file to signal intent:
```
IDEA - <title>.md   ← exploratory or architectural idea, not yet committed
PLAN - <title>.md   ← concrete plan ready for review or execution
MSG  - <title>.md   ← communication artifact (message, decision record, meeting prep)
SPEC - <title>.md   ← specification or requirements doc
DEC  - <title>.md   ← decision record (when a decision needs its own file)
```

**ref/** — no naming convention; filenames should be self-explanatory.

## README Anatomy

Each project README should cover, at minimum:
- Current status (one sentence)
- What the project is and why it matters
- Key decisions made so far
- Links to active WIP docs and relevant reports

## Lifecycle

1. Create `<Project Name>/README.md` with status and context.
2. Drop reference material into `ref/` as you collect it.
3. Use `WIP/` for documents being actively drafted; keep only active files here.
4. Move finished outputs to `Reports/` (with date prefix) or archive them.
5. When a project is complete or paused, update the README status and stop adding files.
