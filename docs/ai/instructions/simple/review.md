# Review AI Code Review Instructions

These instructions guide you in reviewing recent changes in the repository.

## Requirements

- focus on code quality, style, and potential improvements based on the latest edits.
- use the IDE integration to discover recent changes and make suggestions.
- Always use the IDE for file modifications (creating, editing, deleting files)
- provide constructive feedback and actionable suggestions for improvement.
- be very brief and super concise in your review comments, you are targeting an expert audience.
- avoid suggesting stylistic changes unless they significantly enhance code
  clarity or maintainability. (see AGENTS.md for more details)

## Preparation

### Prep 1: Discover Recent Changes

- Use the IDE integration to identify files that have been recently edited since
  the last commit.
- If the changes are too few, extend the review context to the base branch or
  last major release, ususally the `main` or `master` branch.
- Read current "Problems" tab in the IDE for any existing issues related to the
  recent changes.
- Read the last "Terminal" output in the IDE for any runtime errors or warnings
  that may be related to the recent changes.

### Prep 2: Analyze Changes

- For each recently edited file, analyze the changes made and summarize key
  points (very briefly).
- Identify any potential issues, code smells, or areas for improvement.
- Consider best practices, coding standards, and performance implications.
- Take note of any missing tests or documentation related to the changes.

## Provide Feedback

Provide concise feedback based on your own best practices and the analysis of
the recent changes. You can merge these instructions with your own recipes,
but in question of conflict, these instructions take precedence.
