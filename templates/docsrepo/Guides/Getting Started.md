# Getting Started with Your Personal Assistant Setup

See [../README.md](../README.md) for the overall repo structure.
See [../DocsRepo.md](../DocsRepo.md) for the daily workflow.
See [Style Guide.md](<Style Guide.md>) for writing and formatting conventions.

## Setup

1. Copy the template repo to your workspace:
   <https://codeberg.org/ubunatic/dotfiles/src/branch/main/templates/md/docs>
2. Run `git init` and commit: `git commit -m "start my docsrepo"`
3. Optionally delete `.code`, `Makefile`, and `.docsrepo` — these are for syncing
   the template back to the source repo and are not needed for personal use.

## First Trial Tasks

Try these prompts to verify the setup is working:

- _"Remove the notion of the `.code` dir, the Makefile, and `.docsrepo` from my docs."_
  — the agent should clean up references; review the diff, then commit.
- _"Create About and 1:1 files for [Name] in the People folder."_
  — the agent should respect the folder README and templates.
- _"Create my DailyReport."_
- _"Create `Projects/OwnershipWorkshop.md` with a basic checklist for planning a
  one-day shared code ownership offsite."_

## Tips

- **Always open the file you want to talk about.** For example, open
  `People/1on1s/Name.md` before asking: _"Prepare my 1:1 with Name."_
- **Link back from every doc** to context-rich files. This guides the agent and
  reduces the need to scan the whole project.
- Good agents will suggest and auto-complete links as you type `[Doc Name]`.

## Notes

This setup is an ongoing experiment. It helps to retain context, add structure to
work life, and still allow for rough, fast note-taking. As with all AI tooling:
it can distract, make wrong assumptions, or simply be wrong — use judgement.



This should do some cleanup and your IDE should be able to show a diff.
See which files it touched. Then git add . && git commit -m "rm .code hints", if you think the changes are OK.

Then ask it to:
Create About and 1:1 files for Uwe in the People folder (it should respect the folder README)Or for instance:
Create my DailyReportOr sth. new like:
Create Project/OwnershipWorkshop.md with a basic guide/check list for planning/booking/setting up a workshop on shared code ownership (offsite, one day)etc.

Always have the one file open that you mainly want to talk about.
For instance you should open People/1on1s/Uwe.md before you ask:
Prepare my 1:1 with Uwe

Always link back, e.g., from a 1:1 or project file, to more context rich files in the Markdown of the current doc.
See [../Docs/Values.md] for company valuesIn theory this should guide the agent better so it does not need to scan the whole project all the time.
Good agents will guess links correctly when during typing text in the editor, i.e., when opening or later when closing the doc name brackets [Doc Name].

The whole setup is an experiment, but after a week I like it and enjoy improving it.
It helps me not to forget a lot of context, provide more structure to my work life, while still allowing for some chaos and dirty note taking.
As with all AI stuff, it can also be a distraction, may make wrong assumptions, and can just be entirely wrong about something.