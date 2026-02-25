# Docs Folder

The `Docs/` folder holds persistent, role-level context: who you are, what you are working
towards, and how your days are structured. It is the anchor for AI agent sessions and the
starting point for daily work.

See [DocsRepo.md](../DocsRepo.md) for the full daily workflow.

## Files and Their Purpose

| File | Purpose |
|------|---------|
| [Context.md](./Context.md) | Entry point for AI agents — lists all key files with one-line descriptions |
| [Goals.md](./Goals.md) | Your current role, team context, and goals (Now / Next / Later) |
| [DailyReport.md](./DailyReport.md) | Daily working document — refreshed each morning, archived at end of week |
| [Meetings.md](./Meetings.md) | Recurring meetings and weekly schedule |
| [Topics.md](./Topics.md) | Active topics linking out to project and people docs |
| [Values.md](./Values.md) | Company or personal values for reference |
| [Misc.md](./Misc.md) | Miscellaneous context that does not fit elsewhere (benefits, policies, etc.) |
| [Career.md](./Career.md) | Career history, org chart, and role transitions |
| [ProgressCycle.md](./ProgressCycle.md) | Performance review cycle dates and process |
| [archive/](./archive/) | Completed daily reports, kept for reference |

## How to Set This Up

1. **Make a copy of this folder** in your own repository or workspace. This will be your personal
   context hub.
2. **Fill in `Goals.md`** — describe your current role, your team, and your top 3–5 goals.
   Keep it honest and personal; only you will read it.
3. **Fill in `Meetings.md`** — list recurring meetings and your weekly rhythm.
4. **Update `Context.md`** — add a one-line entry for every file the AI agent should
   know about. This is the file you attach when starting an agent session.
5. **Start `DailyReport.md`** — use the template each morning: paste a Slack summary,
   list today's challenges, and draft a time-blocked plan.
6. **Add the rest on demand** — `Values.md`, `Misc.md`, `Career.md`, and `ProgressCycle.md`
   are optional; create them only when the content is useful.

## Key Principle

`DailyReport.md` is a scratch pad, not a permanent record. Keep it messy during the day;
ask the AI to tidy it up before archiving. Archive completed reports into `archive/` with
the date prefix (`YYYY-MM-DD DailyReport.md`) so they are ignored unless explicitly referenced.
