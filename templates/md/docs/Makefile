.PHONY: ⚙️  # make all non-file targets phony

SHELL  := bash
ORIGIN := $(shell source .docsrepo && echo "$$DOCSREPO_ORIGIN")

info: ⚙️  ## show help and variable values
	@echo "Usage: make [target]"
	@echo "Targets:"
	@# extract target before ":" and description after "##"
	@awk -F ':|##' '/^[a-zA-Z0-9_-]+:/{printf "  \033[36m%-15s\033[0m %s\n", $$1, $$3}' Makefile
	@echo
	@echo "Variables:"
	@echo "  ORIGIN = ${ORIGIN}"
	@echo "  DOTFILES = ${DOTFILES}"
	@echo "  GOOGLE_DL = ${GOOGLE_DL}"
	@echo "  URL = ${URL}"
	@echo "  REF_DIR = ${REF_DIR}"
	@echo "  REF_NAME = ${REF_NAME}"

help: ⚙️ info  ## alias for info

origin: ⚙️  ## ensure origin repo is available
	# Creating ORIGIN=${ORIGIN}, see .docsrepo config for details
	mkdir -p "${ORIGIN}"

pull: ⚙️ origin  ## pull latest changes from origin
	cd ${ORIGIN} && git checkout main && git pull

sync: ⚙️ origin  ## sync generic tools and guides from origin
	.code/scripts/sync-docsrepo.sh sync

save: ⚙️ origin  ## save generic tools and guides back to origin
	.code/scripts/sync-docsrepo.sh save

commit: ⚙️  ## commit changes locally
	git add . && git commit -m "Update docs"
	@echo "Don't forget to push your changes to a backup remote repo"

# Google Workspace download tool
GOOGLE_DL := .code/bin/google-dl
URL		   =
REF_DIR    =
REF_NAME   =

build: ⚙️  ## build the Google Workspace download tool
	cd .code && go build -o bin/google-dl ./cmd/google-dl

${GOOGLE_DL}:
	${MAKE} build

google-read: ${GOOGLE_DL}  ## export a Google Workspace doc to stdout  (URL=...)
	${GOOGLE_DL} read ${URL}

google-copy: ${GOOGLE_DL}  ## copy a Google Workspace doc to a ref dir  (URL=... REF_DIR=... REF_NAME=...)
	${GOOGLE_DL} copy ${URL} ${REF_DIR}/${REF_NAME}
