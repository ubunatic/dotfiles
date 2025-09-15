.PHONY: ⚙️  # make all non-file targets phony

SHELL  = bash
OS     = $(shell uname -s)
PREFIX = ${HOME}/.config

ifeq ($(OS),Darwin)
PREFIX = ${HOME}/Library/Application Support
endif

CODES = VSCodium code-oss code code-insiders Code
MERGETOOL = bash -ic "dotapps build" && govsbind

CODE   := $(shell for c in $(CODES); do test -d "$(PREFIX)/$$c" && echo "$$c" && break; done)
PREFIX := $(PREFIX)/$(CODE)/User

get_bindings = sed -e 's|//.*||g' "$(PREFIX)/keybindings.json" | jq -c '.[]' | sort -u

info: ⚙️  ## Show current settings
	@if test -e "$(PREFIX)/keybindings.json"; \
	 then echo "✅ keybindings.json exists in $(PREFIX)"; $(MAKE) bindings; \
	 else echo "❌ keybindings.json does not exist"; \
	 fi

bindings: ⚙️  ## Show current bindings
	@echo "ℹ️ Bindings:"
	@$(get_bindings) | head -n 5
	@echo "..."
	@$(get_bindings) | tail -n 5
	@echo -nu "Total:"; $(get_bindings) | wc -l

diff: ⚙️  ## Show current diff
	@diff -u keybindings.json "$(PREFIX)/keybindings.json" || true

merge: ⚙️  ## Merge  bindings
	@$(MERGETOOL) keybindings.json "$(PREFIX)/keybindings.json"

import: ⚙️  ## Merge existing bindings to dotfiles bindings
	@$(MERGETOOL) keybindings.json "$(PREFIX)/keybindings.json" keybindings.json

clean-backups: ⚙️  ## Clean up backups
	@rm -f keybindings.json.bak.*

test-merge-tool:
	@$(MERGETOOL) keybindings.json "$(PREFIX)/keybindings.json"
	@echo "✅ test-merge succeeded"

install: ⚙️  ## Install  bindings
	@mkdir -p "$(PREFIX)"
	@cp "$(PREFIX)/keybindings.json" "$(PREFIX)/keybindings.json.bak-dotfiles" 2> /dev/null && \
		echo "💾 backed up keybindings.json to $(PREFIX)/keybindings.json.bak-dotfiles" || \
		echo "no existing keybindings.json to backup"
	@cp keybindings.json "$(PREFIX)/keybindings.json"
	@echo "✅ copied keybindings to $(PREFIX)"

uninstall: ⚙️  ## Uninstall bindings
	@rm -f "$(PREFIX)/keybindings.json"
	@mv "$(PREFIX)/keybindings.json.bak-dotfiles" "$(PREFIX)/keybindings.json" 2> /dev/null || true
	@echo "✅ restored pre-install keybindings in $(PREFIX)"

help: ⚙️ usage  ## show this help

include ../../scripts/usage.mk