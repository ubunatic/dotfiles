.PHONY: ⚙️ sync

ROOT          := $(shell git rev-parse --show-toplevel)
BOILER        := ${ROOT}/README.md ${ROOT}/AGENTS.md ${ROOT}/Makefile
BOILER_ORIGIN := ${DOTFILES}/templates/md/docs

info: ⚙️ ## show help and variable values
	@echo "Usage: make [target]"
	@echo "Targets:"
	@# extract target before ":" and description after "##"
	@awk -F ':|##' '/^[a-zA-Z0-9_-]+:/{printf "  \033[36m%-15s\033[0m %s\n", $$1, $$3}' Makefile
	@echo "Variables:"
	@awk -F ':=' '/^[A-Z_]+/{printf "  \033[33m%-15s\033[0m %s\n", $$1, $$2}' Makefile

dotfiles: ⚙️  ## ensure dotfiles repo is available
	test -d ${DOTFILES} || (echo "Error: DOTFILES environment variable is not set or points to a non-existent directory." && exit 1)
	mkdir -p ${DOTFILES}/templates/md/docs

sync: ⚙️ dotfiles  ## sync boilerplate files like AGENTS.md, etc.
	cd ${DOTFILES} && git checkout main && git pull
	cp ${BOILER_ORIGIN}/* ${ROOT}/

save: ⚙️ dotfiles  ## save boilerplate files back to dotfiles
	cp ${BOILER} ${BOILER_ORIGIN}/
	cd ${DOTFILES} && git add templates/md/docs/AGENTS.md
	@echo "Updated AGENTS.md in ${DOTFILES}. Please review and create a PR to merge it back to main."
