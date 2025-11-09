# Instructions for AI Agents

This document provides coding guidelines and conventions for AI agents working on the **ubunatic/dotfiles** repository—a personal collection of shell scripts, terminal apps, and system configurations.

## Agent Role
You are a Coding Assistant specialized in helping with software development tasks.
Your responses should be concise and focused on the technical aspects of the request.
Always consider the context of the request and the files provided as attachments.
Respond in markdown format, prefer files as chat output where appropriate, esp.
when providing longer explanations, reviews, or plans.

## Agent Environment
Assume you are running in an IDE, where you have access to features exposed by the IDE integration, such as:
- access to error logs in the "Problems" tab
- access to project files in the "Explorer" tab
- ability to run terminal commands in the "Terminal" tab
- ability to run tests and see results in the "Test" tab
- ability to propose code changes in one or more "Editor" tabs
- Always use the IDE for file modifications (creating, editing, deleting files)

## Repository Overview

- **Purpose**: A comprehensive collection of personal dotfiles, shell script libraries, custom-built terminal applications, and system configurations for a personalized development environment.
- **Languages**: Primarily Bash and Go. Also includes Python, MicroPython, and AppleScript.
- **Key Directories**:
  - `/shell/`: A library of shell scripts providing common functions, aliases, and environment setup. Sourced by `userrc.sh`.
  - `/apps/`: Home for various custom applications, categorized by language:
    - `go/`: Go applications like `csvconv`, `govsbind`, `gsu`.
    - `bash/`: Shell-based tools like `stackman` and `mclog`.
    - `py/`: Python utilities.
    - `micropy/`: MicroPython projects.
    - `macos/`: macOS specific applications.
    - `stacks/`: Docker Compose stacks for various services (e.g., Immich ML).
    - `unix/`: Unix-specific utilities and configurations (e.g., Prometheus node_exporter).
  - `/config/`: Contains configuration files for tools such as `alacritty`, `starship`, `gnome`, and `vscode`.
  - `/bin/`: Destination for compiled binaries and scripts, intended to be in the user's `PATH`.
  - `/scripts/`: Houses `Makefile` includes (`.mk` files) and other helper scripts for building and testing.
  - `/.forgejo/`: Contains Forgejo CI/CD workflow definitions for continuous integration and testing.

## General Instructions

1. Follow the user's instructions carefully and accurately.
2. Provide clear and concise responses.
3. If you don't know the answer, it's okay to say so.
4. Always prioritize user privacy and security.
5. Understand the project context before making changes.

## Guidelines

- Be respectful and professional.
- Avoid sharing sensitive or personal information.
- Ensure accuracy and reliability in your responses.

## Information Discovery

- Make sure you understand the context and requirements before providing information.
- Read `README.md` files in directories to understand module purposes.
- Use `grep_search` and `semantic_search` to explore the codebase.
- Read referenced documents or files to gather relevant information.
- Check existing code patterns before implementing new features.

## Project-Specific Guidelines

### Installation
- The main entry point for setting up the dotfiles is the `install.sh` script in the root directory.
- The `Makefile` in the root provides various targets for installation, testing, and management of the dotfiles and applications. Run `make` to see available targets.

### Build System
- The project uses **GNU Make** as the primary build tool.
- Include files in `/scripts/` provide reusable Makefile targets.
- Use `make test` to run all tests before committing.

### CI/CD
- This project uses **Forgejo** for its CI/CD pipelines.
- Workflow definitions are located in `/.forgejo/workflows/`.
- The `develop.yml` workflow runs on pushes to the main branch.
- The `pull-request-test.yml` workflow runs on pull requests.

### Shell Library (`/shell/`)
- All shell scripts must be **sourceable** (no direct execution unless in `/apps/bash/`).
- Use the `source` command to load libraries in `userrc.sh`.
- Common utilities are in `common.sh` (logging, file search, prompts).
- Follow the bash coding guidelines below strictly.

### Go Applications (`/apps/go/`)
- Each app has its own package in a subdirectory with a `cmd/` folder.
- Main entry point: `<app>/cmd/main.go` or `<app>/main.go`.
- Use Go modules with the base path `ubunatic.com/dotapps/go/`.
- Binaries are compiled to `/bin/` to be discovered by shell scripts.
- Use structured logging with `log/slog`.
- CLI apps should use `cobra` for command-line parsing.

### Python Applications (`/apps/py/`)
- Use type hints and follow PEP 8 style guidelines.
- Dependencies go in `requirements.txt`.
- Prefer simple, single-file scripts for utilities.

### Configuration Files (`/config/`)
- JSON for VS Code and key bindings.
- System-specific configs in subdirectories (e.g., `gnome/`, `Library/`).

## Coding Guidelines

## Bash
- Use short and descriptive variable names.
- Short-lived vars should be short and `local`.
- Comment your code to explain complex logic. Do not over-comment.
- Avoid doing Math in bash.
- Use `$(...)` for command substitution instead of backticks.
- Use `set -o errexit` instead of `set -e` to make clearer what the intention is.
- Use `set -o pipefail` to ensure that errors in pipelines are caught.

### Conditionals
- NEVER EVER use `if [ <condition> ]` or `if [[ <condition> ]]`, because readability is horrible.
- ALWAYS use `if test <condition>`, because readability is much better.` and it reads like English.
- You MUST always stick to this rule. It is a severe violation of the coding guidelines to not follow this rule!
- Forget that `[ ... ]` and `[[ ... ]]` even exist for conditionals in bash.

### Indentation
- Do not use tabs!
- Use 5 spaces for indentation where possible
  - Use 1 space after `then` and `else` on the same line and then 5 spaces for additional lines.
  - The 5-space indentation ensures commands are aligned properly under `then` and `else`.
  - Put `then`/`else` on new lines with the command on the same line.
  - Example:
    ```bash
    if test -z "$var"
    then echo "Variable is empty"
         echo "Another line"
    else echo "Variable is set"
         echo "Another line"
    fi
    ```
- Use 5 spaces for indentation in functions.
  - Example:
    ```bash
    my_function() {
         echo "This is a function"
         echo "Another line"
    }
    ```
  - The overall 5-space indentation ensures consistency and readability.
    And the IDE will detect the files tab-width correctly.

- Use 1 space between `if` and the condition, break longer conditions with `||` or `&&`.
  - Make sure to indent the continued conditions with 3 spaces, so that the condition aligns nicely with
    the first condition after the `if`.
  - Example:
    ```bash
    if test -z "$var1" ||
       test -z "$var2"
    then echo "One of the variables is empty"
    else echo "Both variables are set"
    fi
    ```
- Use 1 spaces between `for` and the loop variable.
  - Put `do` on a new line.
  - Use 3 spaces between `do` and the command so that the command aligns nicely with the obverall 5-space indentation.
  - Example:
    ```bash
    for item in list
    do   echo "Item: $item  (aligned with 5-space indentation)"
         echo "Another line (5-space indentation)"
    done
    ```
- Allow other indentation for `case` statements, to align the case and the commands.
  - Put `;;` on the same line as the command.
  - Only call short commands in the case branches so that they fit on one line.
  - Create functions for longer commands.
  - Use fully braced `(<pattern>)` for patterns and not just closing-braced `<pattern>)` to improve readability.
  - Put the `(<pattern>)` at the same indentation level as the `case` (like in Go swithch statements).
    - Example:
      ```bash
      case "$var" in
      (value1) echo "Value is 1";;
      (value2) echo "Value is 2";;
      (*)      echo "Other value";;
      esac
      ```