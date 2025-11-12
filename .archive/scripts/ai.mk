.PHONY: ⚙️  # make all non-file targets phony

# assign skill based on target name
ai-%: CHAT_SKILL=$*

chat = echo "Asking AI with skill=$(CHAT_SKILL) and prompt:" && \
	./scripts/ai-prompt.sh preview $(chat_prompt_args) && \
	./scripts/ai-prompt.sh vars $(chat_prompt_args) && \
	./scripts/ai-prompt.sh run $(chat_prompt_args) && \
	echo "AI Request sent successfully."

chat_prompt_args = -s $(CHAT_SKILL)
ifdef DEBUG
chat_prompt_args += -d
endif

CHAT_PROMPT =
export CHAT_PROMPT

ai-%: ⚙️  ## Use AI to assist with the specified CHAT_SKILL (e.g. make ai-docs)
	@$(chat)

ai-chat: CHAT_SKILL=assist
ai-chat: ⚙️  ## General AI chat interface
	@echo "Enter your message for the AI:"
	@{ test -n "$$CHAT_PROMPT" || read -r CHAT_PROMPT; } && $(chat)

## AI Shortcuts

ai:     ai-assist   ## General AI assistance (let the AI decide the skill)
chat:   ai-chat     ## General AI chat interface
skills: ai-skills   ## List AI agent skills based on current project structure
init:   ai-init     ## Initialize AI environment
files:  ai-files    ## Ensure AI agent files match provider-recommended structure
review: ai-review   ## Use AI to review recent changes in the repository
tech:   ai-tech     ## Use AI to identify and remove of non-technical content
docs:   ai-docs     ## Use AI to update documentation based on code changes