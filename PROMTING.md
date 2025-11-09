# AI Prompting System Overview

This document explains how the AI prompting system is structured and used within the `ubunatic/dotfiles` repository, based on the `AGENTS.md`, `Makefile`, `scripts/ai-prompt.sh`, and `scripts/ai.mk` files.

## Core Components

1.  **`scripts/ai-prompt.sh`**: This is the central script for constructing and executing AI prompts.
    *   It gathers context from various sources:
        *   `CHAT_SKILL`: The name of the AI skill to be used (e.g., `assist`, `docs`).
        *   `CHAT_SKILL_FILE`: The markdown file defining the skill's instructions (e.g., `.ai/instructions/simple/assist.md`).
        *   `CHAT_FILES`: A list of additional files whose content should be included as context for the AI.
        *   `CHAT_INVOKER`: The path to the script that invoked the AI (e.g., `scripts/ai-prompt.sh`).
        *   `CHAT_PROMPT`: The user's specific query or instructions.
    *   It formats all this information into a structured prompt (including `<!-- context -->` and `<!-- prompt -->` markers) suitable for an AI model.
    *   It then executes a `CHAT_CMD` (by default `gemini --prompt-interactive`) with the constructed prompt.

2.  **`scripts/ai.mk`**: This Makefile include provides a convenient interface for invoking AI skills using `make`.
    *   **Dynamic Skill Invocation**: It defines a pattern rule `ai-%` that allows users to call any skill by its name (e.g., `make ai-assist`, `make ai-docs`). The `CHAT_SKILL` variable is automatically set to the part after `ai-`.
    *   **`chat` Variable**: This Makefile variable encapsulates the logic for running `ai-prompt.sh`. It first shows a preview, then the variables, and finally executes the AI command.
    *   **Shortcuts**: It provides aliases for common skills:
        *   `make ai`: Invokes `ai-assist` for general assistance.
        *   `make chat`: Invokes `ai-chat`, which prompts the user for a `CHAT_PROMPT` before sending it to the AI.
        *   Other shortcuts like `make skills`, `make init`, `make files`, `make review`, `make tech`, `make docs` are also defined, each mapping to a specific `ai-<skill>` target.

## How to Use

1.  **General Assistance**:
    ```bash
    make ai
    ```
    This will use the `assist` skill (defined in `.ai/instructions/simple/assist.md`) to provide general help based on the current context.

2.  **Specific Skill Invocation**:
    ```bash
    make ai-<skill_name>
    ```
    Replace `<skill_name>` with the desired skill (e.g., `make ai-docs` to use the `docs` skill).

3.  **Interactive Chat**:
    ```bash
    make chat
    ```
    This will prompt you to enter a message, which will then be sent to the AI using the `assist` skill.

4.  **Adding Context Files**:
    The `CHAT_FILES` variable can be extended to include more files in the AI's context. This is typically done by modifying the `Makefile` or by passing arguments to `ai-prompt.sh` directly (though `ai.mk` simplifies this).

## Defining New AI Skills

To add a new AI skill:

1.  **Create a Skill Definition File**: Create a new markdown file (e.g., `.ai/instructions/simple/my_new_skill.md`) that describes the purpose and instructions for your new skill.
2.  **Invoke via Makefile**: You can then invoke this skill using `make ai-my-new_skill`. The `ai.mk` system will automatically find and use your skill definition file.
