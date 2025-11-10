.PHONY: ⚙️  # make all non-file targets phony

help: ⚙️ usage-all  ## Show help for all Makefile targets

# use login shell to source dotfiles
SHELL := bash

# Set current Go project directory and name
go_project_dir := apps/go/gololog
go_project	   := gololog

include scripts/usage.mk
include scripts/ai.mk
include scripts/go.mk

test: dotfiles-testall  ## run all tests
dotfiles-testall: ⚙️  ## run all shell tests
	bash -i -c 'dotfiles-testall'

integration: ⚙️  ## run integration test
	scripts/integration-test.sh
