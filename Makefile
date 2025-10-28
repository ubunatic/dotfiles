.PHONY: ⚙️  # make all non-file targets phony

# use login shell to source dotfiles
SHELL = bash -il

test: ⚙️  ## run all shell tests
	dotfiles-testall
