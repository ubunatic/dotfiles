.PHONY: ⚙️  # make all non-file targets phony

OS    = $(shell uname -s)
SHELL = bash

ifeq ($(OS),Darwin)
PREFIX = ${HOME}/Library/Application Support/VSCodium/User/
else
PREFIX = ${HOME}/.config/VSCodium/User/
endif

get_bindings = sed -e 's|//.*||g' "$(PREFIX)/keybindings.json" | jq -c '.[]'

info: ⚙️
	@if test -e "$(PREFIX)/keybindings.json"; \
	 then echo "✅ keybindings.json exists"; $(MAKE) bindings; \
	 else echo "❌ keybindings.json does not exist"; \
	 fi

bindings: ⚙️
	@echo "ℹ️ Bindings:"
	@$(get_bindings) | head -n 5
	@echo "..."
	@$(get_bindings) | tail -n 5
	@echo -n "Total:"; $(get_bindings) | wc -l

install: ⚙️
	mkdir -p "$(PREFIX)"
	cp keybindings.json "$(PREFIX)/keybindings.json"
	@echo "✅ copied keybindings to $(PREFIX)"

help: ⚙️ usage  ## show this help

include ../../scripts/usage.mk