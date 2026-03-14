.PHONY: ⚙️  # make all non-file targets phony

SHELL    := bash
PROMPT   := This is an AI test -- if you see this message I messed sth. up
SLACKBOT := .code/scripts/slackbot.applescript

# Load variables from .docsrepo config file
SLACKBOT_URL  := $(shell source .docsrepo && echo "$$DOCSREPO_SLACKBOT_URL")
SLACKBOT_HINT := $(shell source .docsrepo && echo "$$DOCSREPO_SLACKBOT_HINT")
ORIGIN        := $(shell source .docsrepo && echo "$$DOCSREPO_ORIGIN")

# Some tools use env vars
export DOCSREPO_SLACKBOT_URL=$(SLACKBOT_URL)

info: ⚙️  ## show help and variable values
	@.code/scripts/info.sh

help: ⚙️ info  ## alias for info

sync: ⚙️  ## sync generic tools and guides from origin
	.code/scripts/sync-docsrepo.sh sync

save: ⚙️  ## save generic tools and guides back to origin
	.code/scripts/sync-docsrepo.sh save

list-save: ⚙️  ## list files that would be saved to origin
	.code/scripts/sync-docsrepo.sh list-save

list-sync: ⚙️  ## list files that would be synced from origin
	.code/scripts/sync-docsrepo.sh list-sync

sync-vars: ⚙️  ## sync only the .docsrepo config file from origin
	.code/scripts/sync-docsrepo.sh vars

commit: ⚙️  ## commit changes locally
	git add . && git commit -m "Update docs"
	@echo "Don't forget to push your changes to a backup remote repo"

time: ⚙️  ## show current time
	@date +"%Y-%m-%d %H:%M:%S"

date: ⚙️  ## show current date
	@date +"%Y-%m-%d"

copy: ⚙️  ## copy a file from SRC to DST (SRC=... DST=...)
	@cp ${SRC} ${DST}

move: ⚙️  ## move a file from SRC to DST (SRC=... DST=...)
	@mv ${SRC} ${DST}


## Tool Integrations

code: ⚙️  ## open a file in the default code editor (FILE=...)
	@code ${FILE}

slackbot: ⚙️  ## send a prompt to Slackbot (PROMPT=...)
	test -n "$$DOCSREPO_SLACKBOT_URL" # ensure URL is set in env
	test -n "$(SLACKBOT_HINT)"        # ensure the hint is set as make var
	test -n "$(PROMPT)"               # ensure the prompt is set as make var
	${SLACKBOT} "${PROMPT} (Note: ${SLACKBOT_HINT})"
