.PHONY: 🤖  # make all non-file targets phony

# assign skill based on target name
ai-%: CHAT_SKILL=$*
ai-%: SHELL=$$SHELL -l

# CHAT_PROMPT is used as env var to avoid shell quoting issues
CHAT_PROMPT =
export CHAT_PROMPT

chat = CHAT_PROMPT="$(chat_context) $${CHAT_PROMPT:-$(chat_prompt_fallback)}"; \
	   echo "Asking AI with skill:$(CHAT_SKILL) model:$(chat_model) and prompt: '$$CHAT_PROMPT'"; \
	   $(chat_cmd) $(chat_cmd_args) "$$CHAT_PROMPT"

# Default fallback prompt if CHAT_PROMPT is not set
chat_prompt_fallback = Assist me using your '$(CHAT_SKILL)' skill.

# Files to always include in the chat context
chat_files = AGENTS.md README.md CONTRIBUTING.md DOCS.md '$(chat_skill_file)'

# Construct the chat context with files and skill instructions.
# NOTE: Do not use any double quotes! This will be become part of the quoted prompt.
chat_context = context: $(chat_files) \
	skill=$(CHAT_SKILL) \
	skills_dir='$(chat_skills_dir)' \
	skill_file='$(chat_skill_file)' \
	-- \
	Read the skill_file, follow its instructions, and adhere to the following prompt:

# Gemini sometimes confuses workspace path, so we set it explicitly
export GEMINI_CLI_IDE_WORKSPACE_PATH=$(CURDIR)

chat_skills_dir = .ai/instructions/simple
chat_skill_file = $(chat_skills_dir)/$(CHAT_SKILL).md

# AI chat command configuration
# Set this to 'gemini' or 'code chat' or other AI CLI tool as needed
chat_cmd := $(shell which gemini 2>/dev/null || echo "code chat")

ifeq ($(chat_cmd),gemini) # Use interactive-prompt mode for gemini CLI
chat_vscode_ext = google.gemini-cli-vscode-ide-companion
# chat_model = auto
# chat_cmd_args = -m $(chat_model)
ifdef DEBUG
chat_cmd_args += -d
endif
chat_cmd_args += -i
endif

ai-%: 🤖  ## Use AI to assist with the specified CHAT_SKILL (e.g. make ai-docs)
ifdef DEBUG
	# Debug mode enabled, see chat command below:
	# $(chat)
endif
	@# Run the chat command with the specified skill
	@$(chat)


## AI Commands

ai-chat: CHAT_SKILL=assist
ai-chat: 🤖  ## General AI chat interface
	@echo "Enter your message for the AI:"
	@{ test -n "$$CHAT_PROMPT" || read -r CHAT_PROMPT; } && $(chat)

ai-init:   🤖  ## Initialize AI environment
ai-docs:   🤖  ## Use AI to update documentation based on code changes
ai-update: 🤖  ## Update AI tools
	@brew upgrade || echo "Skipping upgrade: Homebrew not installed."

ai-ext: 🤖  ## Install VSCode extension for AI
	@code --install-extension $(chat_vscode_ext) --force || echo "VSCode extension installation failed. Is VSCode installed?"
	@echo "Getting information about the Gemini CLI IDE server..."
	@echo GEMINI_CLI_IDE_SERVER_PORT=$$GEMINI_CLI_IDE_SERVER_PORT
	@echo GEMINI_CLI_IDE_WORKSPACE_PATH=$$GEMINI_CLI_IDE_WORKSPACE_PATH
	@echo "You may need to restart VSCode for the extension to take effect."

ai-files: CHAT_SKILL=assist
ai-files: 🤖  ## Open the main AI instructions files
	@code $(foreach file,$(chat_files),-g $(file))

## AI Shortcuts

ai:      🤖 ai-assist   ## General AI assistance (let the AI decide the skill)
chat:    🤖 ai-chat     ## General AI chat interface
skills:  🤖 ai-skills   ## List AI agent skills based on current project structure
files:   🤖 ai-files    ## Ensure AI agent files match provider-recommended structure
review:  🤖 ai-review   ## Use AI to review recent changes in the repository
tech:    🤖 ai-tech     ## Use AI to identify and remove of non-technical content
ext:     🤖 ai-ext      ## Install VSCode extension for AI
