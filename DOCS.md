# Documentation Index

This document provides an index of documentation files in the
`ubunatic/dotfiles` repository.

## General Documentation

- [README.md](README.md): Main entry point — overview, usage, and licensing.
- [CONTRIBUTING.md](CONTRIBUTING.md): Coding standards, testing, build system,
  and pull request process.
- [SECURITY.md](SECURITY.md): Security policy, vulnerability reporting, and
  best practices.
- [AGENTS.md](AGENTS.md): Coding guidelines and conventions for AI agents,
  including Bash style rules and project structure.
- [CLAUDE.md](CLAUDE.md): Claude Code-specific instructions (extends AGENTS.md
  with Claude Code CLI conventions).

## AI Documentation

All AI-related documentation lives under [docs/ai/](docs/ai/).

- [docs/ai/README.md](docs/ai/README.md): Overview of the AI docs folder
  and how to use it.
- [docs/ai/prompting.md](docs/ai/prompting.md): How to use skills and
  structure prompts for AI assistants.
- [docs/ai/instructions/README.md](docs/ai/instructions/README.md): Notes on
  the AI instructions directory.

### AI Skill Definitions

Located in [docs/ai/instructions/simple/](docs/ai/instructions/simple/):

| Skill    | File                           | Purpose                            |
|----------|--------------------------------|------------------------------------|
| assist   | `instructions/simple/assist.md`| General assistance                 |
| docs     | `instructions/simple/docs.md`  | Update documentation               |
| review   | `instructions/simple/review.md`| Review recent code changes         |
| init     | `instructions/simple/init.md`  | Initialize/update AI config files  |
| skills   | `instructions/simple/skills.md`| List skills available in context   |
| tech     | `instructions/simple/tech.md`  | Remove non-technical content       |
| help     | `instructions/simple/help.md`  | General help                       |

### AI Projects

- [docs/ai/projects/AgenticCoding.md](docs/ai/projects/AgenticCoding.md):
  Agentic coding environment setup plan.

## Template Files

- [.forgejo/ISSUE_TEMPLATE/bug_report.md](.forgejo/ISSUE_TEMPLATE/bug_report.md):
  Bug report template (Forgejo).
- [.forgejo/ISSUE_TEMPLATE/feature_request.md](.forgejo/ISSUE_TEMPLATE/feature_request.md):
  Feature request template (Forgejo).
- [.forgejo/PULL_REQUEST_TEMPLATE.md](.forgejo/PULL_REQUEST_TEMPLATE.md):
  Pull request template (Forgejo).
- [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md):
  Pull request template (GitHub).
- [.github/README.md](.github/README.md): GitHub files and Forgejo relation.

## Application Documentation

- [apps/bash/stackman/README.md](apps/bash/stackman/README.md): Stackmanager
  tool.
- [apps/macos/appcloser/README.md](apps/macos/appcloser/README.md): macOS
  appcloser application.
- [apps/macos/appcloser/DEVNOTES.md](apps/macos/appcloser/DEVNOTES.md):
  appcloser development notes.
- [apps/micropy/AI.md](apps/micropy/AI.md): MicroPython coding conventions.
- [apps/micropy/EP-0249/README.md](apps/micropy/EP-0249/README.md): EP-2049
  Pico setup.
- [apps/stacks/immich.ml/README.md](apps/stacks/immich.ml/README.md): Immich
  ML container setup.

## Configuration Documentation

- [config/Library/Keyboard Layouts/README.md](config/Library/Keyboard%20Layouts/README.md):
  Custom "German - PC" macOS keylayout.
- [config/vscode/README.md](config/vscode/README.md): VSCode keybindings.

## Shell Library Documentation

- [shell/README.md](shell/README.md): Shell micro-library overview and usage.
