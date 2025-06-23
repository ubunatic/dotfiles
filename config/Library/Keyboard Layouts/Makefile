.PHONY: ⚙️

SHELL  = bash

PREFIX       = $(HOME)/Library
LAYOUTS_DIR  = $(PREFIX)/Keyboard Layouts
BINDINGS_DIR = $(PREFIX)/KeyBindings

xmllint = python3 ../../../scripts/xmllint.py

all: icns lint ⚙️
icns: German-PC.icns ⚙️
lint: German-PC.lint ⚙️
install: German-PC.install ⚙️
uninstall: German-PC.uninstall ⚙️

list: ⚙️
	@echo "Available keyboard layouts:"
	@ls -1 *.keylayout | sed 's/\.keylayout//'

list-installed: ⚙️
	@echo "Installed keyboard layouts in $(PREFIX):"
	@ls -1 "$(PREFIX)"/**/*.keylayout 2>/dev/null | sed 's|^.*/||; s/\.keylayout//'
	@echo "Installed keyboard bindings in $(PREFIX):"
	@ls -1 "$(PREFIX)"/**/*.dict 2>/dev/null || true

browse-installed: ⚙️
	@echo "opening Keyboard Layouts directory ..."
	mc "$(PREFIX)"

edit-icns: ⚙️
	@echo "opening German-PC.icns in icon editor ..."
	inkscape German-PC.iconset/Assets/DE-PC.svg

settings: ⚙️
	@echo "opening Keyboard Layouts settings ..."
	open "x-apple.systempreferences:com.apple.preference.keyboard?KeyboardLayouts"

logout: ⚙️
	@echo "logging out to apply changes ..."
	osascript -e 'tell application "System Events" to log out'

test: ⚙️
	@echo "Testing German-PC layout in TextEdit ..."
	osascript test.applescript

dirs: ⚙️
	@mkdir -p "$(LAYOUTS_DIR)"
	@mkdir -p "$(BINDINGS_DIR)"

%.icns: %.iconset
	rm -f $</*-iOS-*
	rm -f $</*-watchOS-*
	iconutil -c icns "$<"

%.install: %.icns dirs ⚙️
	cp $*.icns "$(LAYOUTS_DIR)/"
	cp $*.keylayout "$(LAYOUTS_DIR)/"
	cp ../KeyBindings/DefaultKeyBinding.dict "$(BINDINGS_DIR)/"
	@echo "Installed layouts $* and default bindings to $(PREFIX) ✅"
	@echo; grep -A +4 'Post Install' README.md

%.uninstall: %.uninstall ⚙️
	@echo "Uninstalling layout $* from $(PREFIX) ..."
	@rm -f "$(LAYOUTS_DIR)"/$*.*
	@rm -f "$(BINDINGS_DIR)/DefaultKeyBinding.dict"
	@echo "Uninstalled layout and default bindings $* from $(PREFIX) ✅"

%.lint: %.keylayout ⚙️
	@echo "Linting $<"
	@$(xmllint) <(sed -e 's|"&.*;"|""|g' "$<")
	@echo "Linting $< ✅"
