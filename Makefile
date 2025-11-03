.PHONY: ⚙️  # make all non-file targets phony

help: ⚙️ usage-all  ## Show help for all Makefile targets

include scripts/usage.mk
include scripts/ai.mk
include scripts/go.mk

# use login shell to source dotfiles
SHELL = bash -il

test: dotfiles-testall  ## run all tests
dotfiles-testall: ⚙️  ## run all shell tests
	dotfiles-testall

integration: ⚙️  ## run integration test
	scripts/integration-test.sh
