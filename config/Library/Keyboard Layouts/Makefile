.PHONY: ⚙️

SHELL  = bash
PREFIX = $(HOME)/Library/Keyboard Layouts

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
	@ls -1 "$(PREFIX)"/*.keylayout | sed 's|^.*/||; s/\.keylayout//'

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

%.icns: %.iconset
	rm -f $</*-iOS-*
	rm -f $</*-watchOS-*
	iconutil -c icns "$<"

%.install: %.icns ⚙️
	mkdir -p "$(PREFIX)"
	cp $*.icns "$(PREFIX)/"
	cp $*.keylayout "$(PREFIX)/"
	@echo -----
	@grep -A +3 'Post Install' README.md | grep -v 'Post Install'
	@echo -----
	@echo "Installed layouts $* to $(PREFIX) ✅"

%.uninstall: %.uninstall ⚙️
	@echo "Uninstalling layout $* from $(PREFIX) ..."
	@rm -f "$(PREFIX)"/$*.*
	@echo "Uninstalled layout $* from $(PREFIX) ✅"

%.lint: %.keylayout ⚙️
	@echo "Linting $<"
	@$(xmllint) <(sed -e 's|"&.*;"|""|g' "$<")
	@echo "Linting $< ✅"
