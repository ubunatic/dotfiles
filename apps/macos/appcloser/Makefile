.PHONY: ⚙️

SHELL  = /bin/bash

app    = appcloser
script = $(app).applescript
prefix = $(HOME)/Library/LaunchAgents
bin    = $(CURDIR)/$(app)
plist  = com.ubunatic.macos.$(app).plist
xml_marker      = <!-- APP_PATH -->
xml_replacement = <!-- APP_PATH --><string>$(bin)</string>

build: ⚙️
	osacompile -o $(bin) $(script)
	chmod +x $(script) $(bin)
	ls -la $(bin) $(script)

clean: ⚙️
	rm -f $(bin)

install: ⚙️
	mkdir -p $(prefix)
	sed 's|$(xml_marker).*|$(xml_replacement)|' $(plist) > $(prefix)/$(plist)
	cat $(prefix)/$(plist)

uninstall: ⚙️
	rm -f $(prefix)/$(script)

list ls: ⚙️
	@echo "Listing macOS app scripts..."
	ls -l $(prefix)

run: ⚙️
	osascript $(script)

test: ⚙️
	@echo "Testing macOS app..."
