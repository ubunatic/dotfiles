# Agentic AI Instructions

See [README.md](./README.md) for the overall structure and purpose of this repo.
See [PROJECT.md](./PROJECT.md) for the overall project context.

---

## Auto Session Agents

> **IMPORTANT: Execute automatically on every session — do not wait to be asked.**

This repo uses two background agents that run alongside the main conversation:

| Agent | Role | Tools | Invocation |
|---|---|---|---|
| `personal-assistant` | Active watcher — steps in with advice, focus checks, coaching | Read-only + Agent | Auto-start on first message |
| `note-taker` | Passive worker — captures summaries, files notes, keeps repo tidy | Read + Write + Edit | Background, after substantive exchanges |
| `ollama-vision` | Local vision worker — OCR and image analysis via Ollama | Bash + Read | **First taker** for any image task |

### Image Processing

**Any request involving an image file must go to `ollama-vision` first.** This includes:
- Scans (invoices, receipts, letters, contracts)
- Screenshots shared by the user
- Diagrams, charts, or handwritten notes
- Any file path ending in `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`

The main session and all other agents must delegate image tasks to `ollama-vision` as a subagent rather than attempting to process images directly.

### Session Start

On the **first user message**, invoke the `personal-assistant`:

```
Session start. Check DailyReport.md and Goals.md for open items.
Check git log for changes in the last 24h.
Return a 3-bullet status: what's open, what was done, what to focus on now.
Today's date: <insert current date>
```

Show the result before addressing anything else.

### Continuous Note Capture

After each **substantive exchange** (decisions, action items, voice input):
- Invoke the `note-taker` in the background with a 2–3 sentence summary + any action items.

### Inbox Processing

The `Inbox/` folder is a landing zone for raw, unprocessed input.

- When the user says **"process my inbox"**, **"file what's in Inbox"**, or similar: invoke the `note-taker` to read each file, file it in the right folder, and delete it from Inbox.
- At **session start**, check if `Inbox/` has any files (excluding `README.md`). If so, mention it in the status report so the user can decide whether to process now.
- The `note-taker` should infer destination from content — `Docs/`, `Projects/`, `People/`, etc. — and apply the standard folder structure.

### Session End

When the user says "done", "bye", "wrap up", "end of day", or "summarise":
- Invoke `note-taker`: "End of session. Write a session summary to `Sessions/YYYY-MM-DD.md` (use today's date). Sections: Done, Decisions, Open/Next. Also update DailyReport.md with a brief entry. Flag any open items."

---

## User Profile

> Optional — only read when personalising tone, coaching, or delegation decisions.

Repo owner profile: [People/UserProfile.md](People/UserProfile.md)

**Team context**: see [People/README.md](People/README.md) for roster, traits, name spellings, and communication styles.

---

## Tools

Run `make help` for the full list. Key commands:

- `make date` / `make time` — current date/time
- `make copy SRC=... DST=...` / `make move SRC=... DST=...` — file operations
- `make code FILE=...` — open in editor
- `make slackbot PROMPT=...` — query Slack
- `gh` — GitHub CLI

**Rules:**
- Always use `make` targets — never call scripts directly via `python3` or `bash`. If no target exists, add one to the Makefile first.
- Never run bare `python3 -c` or inline scripts in the main session — use `make` targets or escalate to the developer agent.
- `himalaya` commands always require `dangerouslyDisableSandbox: true` — the email server is blocked by the default sandbox.
- Do not `source` scripts or run `osascript` or `open` directly.
- **Linear MCP**: never assign tickets — leave assignee blank.

---

## Markdown Conventions

**Links**: Always use `[](<>)` for paths with spaces. Never use `%20`. Fix incorrect links proactively.

**Mermaid diagrams**: Never use `\n` inside node labels — it does not render. Use quoted multi-word strings instead, or split into separate nodes. Keep each label to a single line of text.

**Style**: See [Guides/Style Guide.md](<Guides/Style Guide.md>) for writing style and formatting conventions.

---

## Access Policy

This is a corporate docs repo. All content is in scope. No private folder exists — private content lives in a separate repo.
