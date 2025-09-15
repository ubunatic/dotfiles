include ../../scripts/usage.mk

help: usage  ## Show this help message

PREFIX ?= $(HOME)/.config/input-remapper-2
PRESET ?= $(PREFIX)/presets/$(device)

device   = $(shell $(goremapper) -get-device 2> /dev/null || echo "unknown")
autoload = $(shell jq -r '.autoload' config.json)
active   = $(shell jq -r '.autoload' "$(PREFIX)/config.json" 2> /dev/null || echo "{}")
services = input-remapper.service input-remapper-daemon.service
goremapper = go run goremapper/main.go -config "$(PREFIX)/config.json"

vars:  ## Show variables
	# PREFIX:   '$(PREFIX)'"
	# PRESET:   '$(PRESET)'"
	# device:   $(device)"
	# autoload: $(autoload)"
	# active:   $(active)"
	# services: $(services)"

install:  ## Install input-remapper bindings
	@echo "Installing input-remapper bindings..."
	mkdir -p "$(PRESET)"
	cp -r macstyle.json "$(PRESET)/"

set-preset:  ## Set input-remapper preset for active device
	$(goremapper) -get-device
	$(goremapper) -set-preset macstyle
	echo "✅ Set preset 'macstyle' for device '$(device)'"
	@$(MAKE) autoload

import:  ## Import existing input-remapper preset
	@echo "Importing input-remapper bindings..."
	cp "$(PRESET)/macstyle.json" macstyle.json
	@$(MAKE) autoload

uninstall:  ## Uninstall input-remapper bindings
	@echo "Uninstalling input-remapper bindings..."
	rm -f "$(PRESET)/macstyle.json"
	rmdir "$(PRESET)" 2> /dev/null || true

restart: service-restart  ## Restart input-remapper service
start:   service-start    ## Start input-remapper service
stop:    service-stop     ## Stop input-remapper service
enable:  service-enable   ## Enable input-remapper service
disable: service-disable  ## Disable input-remapper service
status:  service-status   ## Show status of input-remapper service
autoload:  ## Reload input-remapper autoload mappings
	input-remapper-control --command autoload

reload:   ## Reload input-remapper service
	@echo "Reloading input-remapper service..."
	sudo systemctl daemon-reload
	$(MAKE) restart

service-%:; sudo systemctl $* $(services)

diff:  ## Show diff of input-remapper bindings
	@echo "Mapping differences:"
	@diff --color -u "$(PRESET)/macstyle.json" macstyle.json || true

info: vars  ## Show info about input-remapper bindings
	# Input Remapper Bindings Info:
	# Config files:
	@tree "$(PREFIX)"
	# Autoload mappings:
	# $(autoload)
	# Active mappings:
	# $(active)
