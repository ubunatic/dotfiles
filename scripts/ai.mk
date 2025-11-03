.PHONY: ⚙️  # make all non-file targets phony

# AI Chat command, set this variable to change the command used for AI interactions
ai_chat = code chat

ai-init: ⚙️  ## Initialize AI environment
	$(ai_chat) "create or update my AGENTS.md file based on the current project \
		structure and goals"

ai-files: ⚙️  ## Ensure AI agent files match provider-recommended structure
	$(ai_chat) "also make sure the .github/ or equivalent directory has the \
		necessary files to comply with best practices for AI agents in this \
		repository"

ai-review: ⚙️  ## Use AI to review recent changes in the repository
	$(ai_chat) "review the recent changes in this repository and provide \
		feedback on code quality, style, and potential improvements"

ai-tech-only: ⚙️  ## Use AI to identify and remove of non-technical content
	$(ai_chat) "analyze the repository and identify any non-technical content \
		esp. social, cultural, or political statements, advice, rules, and \
		similar. This is a purely technical repository and should not take any \
		position on such matters. Suggest removal of such content."

ai-update-docs: ⚙️  ## Use AI to update documentation based on code changes
	$(ai_chat) "analyze the code changes in this repository and update the \
		documentation accordingly to reflect the latest codebase"
