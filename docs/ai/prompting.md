# AI Prompting Guide

This document explains how AI skills and prompts are structured in the
`ubunatic/dotfiles` repository.

## Overview

AI assistants (Claude Code, Gemini CLI, etc.) are invoked directly via their
CLI interfaces. No Make targets are needed.

The main instruction files the AI reads on startup are:

- `AGENTS.md` — coding guidelines and conventions (used by most AI tools)
- `CLAUDE.md` — Claude Code-specific instructions (used by Claude Code CLI)

## Skill Definitions

Skill files are Markdown documents in `docs/ai/instructions/simple/`. Each
file defines a named task an AI assistant can perform. Pass the skill file
as context when prompting the AI.

### Available Skills

| Skill      | File                                       | Purpose                              |
|------------|--------------------------------------------|--------------------------------------|
| `assist`   | `instructions/simple/assist.md`            | General assistance                   |
| `docs`     | `instructions/simple/docs.md`              | Update documentation                 |
| `review`   | `instructions/simple/review.md`            | Review recent code changes           |
| `init`     | `instructions/simple/init.md`              | Initialize/update AI config files    |
| `skills`   | `instructions/simple/skills.md`            | List skills available in context     |
| `tech`     | `instructions/simple/tech.md`              | Remove non-technical content         |
| `help`     | `instructions/simple/help.md`              | General help                         |

## Defining New Skills

Create a Markdown file in `docs/ai/instructions/simple/` that describes the
purpose and step-by-step instructions for the skill. Name it after the skill
(e.g. `my-skill.md`).

## Projects

Project plans and notes from AI-assisted work are stored in
`docs/ai/projects/`. Active work goes there; completed work stays for
reference.
