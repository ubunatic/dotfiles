# Using a Docs Repo as Productivity Booster

This guide explains how to use a docs repository as a productivity booster. It covers
the setup, daily workflow, and principles for keeping it useful over time.

See [Company Values](Docs/Values.md) for the values that guide work and culture.
See [Goals](Docs/Goals.md) for current goals and overarching objectives.
See [Daily Notes](Docs/DailyNotes.md) for quick, unstructured note-taking.
See [Daily Report](Docs/DailyReport.md) for daily updates and reflections.
See [Executive Summary](Docs/ExecutiveSummary.md) for high-level summaries of key topics.

> Note: Create empty files on-demand.
> In VSCode just CMD+click it and confirm the prompt to create it.
> This avoids cluttering the repo with unused files and folders.

## Daily Docs Repo Process

A lean, IDE-centric workflow for working with an AI agent in this docs repo.

### Morning Kickoff (10 min)
1. Open [DailyReport.md](Docs/DailyReport.md) — start fresh or ask AI to carry over key items from yesterday
2. **Mondays only**: Archive last week's report: `git mv 'Docs/DailyReport.md' 'Docs/archive/YYYY-MM-DD DailyReport.md'`, then create a fresh one
3. Paste Slack summary into the **Preface** section (Slackbot query in the template)
4. Fill the **Daily Plan** based on [Goals.md](Docs/Goals.md) NNL and Slack context
5. Ask the AI agent: "What's on my plate today based on my NNL?"

> Note: If you have long-running tasks, you may do the routine only once every few days.
> Just stay in the open doc as needed and ask the agent later to close the loop.
> If it gets too busy, let the agent summarise and start a fresh doc. This should work even on the same day if needed.

### During the Day
- **Capture quickly**: Dump rough notes into the **Notes** section of DailyReport.md
- **Create detailed docs**: For any significant topic, create a new doc and link it from the Daily Report
- **Delegate formatting**: Write messy, ask the agent to "tidy this up per AGENTS.md"
- **Research via agent**: For any TL/leadership task, ask the agent to draft content based on existing docs
- **Stay in the IDE**: Avoid context-switching to Notion, Confluence, Slack, etc. for documentation work

### End of Day (5 min)
1. Ask the agent: "Summarise what I worked on today based on recent file changes" → paste into **Daily Summary** section of [DailyReport.md](Docs/DailyReport.md)
2. Move completed items in [Goals.md](Docs/Goals.md) NNL section
3. Commit changes with a meaningful message (e.g. "Daily update: added notes on X, completed Y task") and push to remote if desired

> Note: Do not push changes to remote repos that can be accessed by others.
> Your notes will contain private data and may be messy.
> Your personal remote should be for backup only.

> Note: The "AI: Remind me" directives in this doc are aspirational intent statements, not functional timers.
> VS Code AI agents are reactive — they respond to prompts, not the clock.
> Treat them as a reminder to yourself to trigger the workflow manually.

### Weekly Review (10 min)
- Archive last week's [DailyReport.md](Docs/DailyReport.md) into `Docs/archive/` with date prefix (if not done Monday)
- Review the Projects folder for stale items
- Ask the agent: "What docs haven't been touched in 2 weeks?"
- Quick-check [Context.md](Docs/Context.md): are all key files still listed and links valid?
- Archive or delete what's no longer relevant

### Principles
- **MIEFO**: Keep docs concise; your future self is "others" too
- **Own the outcome**: Update the NNL before diving into work
- **Tell the story**: Link context rather than repeating it; use relative paths

## Google Workspace Access

> The repo included an AI-coded `google-dl` tool that broke often. It is removed now.
> The next try will use `rclone`for this with a more robust setup.

### Authentication

See [.code/GOOGLE_SETUP.md](.code/GOOGLE_SETUP.md) for the one-time setup guide.


## Open Issues

- **Archiving**: New files accumulate daily. The weekly review is a start; consider automating
  reminders or adding a structured archive folder.

- **Privacy**: Notes contain private data. Do not push to shared remote repos. Add safeguards
  or reminders to prevent accidental exposure.

- **Context Window**: The material will grow quickly and the AI agent's context window is limited.
  Trust the agent to stay lean and use sub-agents automatically; avoid manual pruning until
  there is clear evidence it is needed.
  > Do not prematurely prune or summarise. Monitor how the agent performs with full context
  > before cutting anything down. Ideally archived docs are ignored unless explicitly referenced.
