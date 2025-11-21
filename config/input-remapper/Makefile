.PHONY: ⚙️  # make all non-file targets phony

include ../../scripts/usage.mk

help: usage  ## Show this help message

PREFIX  ?= $(HOME)/.config/input-remapper-2
PRESET  ?= $(PREFIX)/presets/$(device)
PATH    := $(abspath ../../../bin):$(PATH)
SOURCES := $(wildcard goremapper/*.go)
BINARY  := ../../../bin/goremapper

device_num = 1
device   = $(shell $(goremapper) -get-device $(device_num) 2> /dev/null || echo "unknown")
autoload = $(shell jq -r '.autoload' config.json)
active   = $(shell jq -r '.autoload' "$(PREFIX)/config.json" 2> /dev/null || echo "{}")
services = input-remapper.service input-remapper-daemon.service
goremapper = goremapper -config "$(PREFIX)/config.json"
backup_num = $$(find .backup -maxdepth 1 -name "macstyle-*.json" | wc -l | tr -d ' ')

build: ⚙️ $(BINARY)  ## Build goremapper binary

$(BINARY): $(SOURCES)
	@echo "⚙️  Building goremapper binary at $@ ..."
	@cd goremapper && go build -o $@ main.go
	goremapper -h
	@echo "✅ Built goremapper binary (see usage above)"

vars: ⚙️  ## Show variables
	# PREFIX:   '$(PREFIX)'
	# PRESET:   '$(PRESET)'
	# device:   $(device)
	# autoload: $(autoload)
	# active:   $(active)
	# services: $(services)

install: ⚙️  ## Install input-remapper bindings
	@echo "Installing input-remapper bindings..."
	mkdir -p "$(PRESET)"
	cp -r macstyle.json "$(PRESET)/"

set-preset: ⚙️  ## Set input-remapper preset for active device
	$(goremapper) -get-device $(device_num)
	$(goremapper) -set-preset macstyle -device '$(device)'
	@echo "✅ Set preset 'macstyle' for device '$(device)'"
	@$(MAKE) autoload

backup: ⚙️  ## Backup existing input-remapper preset
	@echo "Backing up input-remapper bindings..."
	@mkdir -p .backup
	cp "$(PRESET)/macstyle.json" .backup/macstyle-installed-$(backup_num).json
	cp "macstyle.json" .backup/macstyle-$(backup_num).json
	@echo "✅ Backed up to 'macstyle-$(backup_num).json'"

import: ⚙️ backup  ## Import existing input-remapper preset
	@echo "Importing input-remapper bindings..."
	cp "$(PRESET)/macstyle.json" macstyle.json
	@$(MAKE) autoload

uninstall: ⚙️  ## Uninstall input-remapper bindings
	@echo "Uninstalling input-remapper bindings..."
	rm -f "$(PRESET)/macstyle.json"
	rmdir "$(PRESET)" 2> /dev/null || true

restart:  ⚙️ service-restart  ## Restart input-remapper service
start:    ⚙️ service-start    ## Start input-remapper service
stop:     ⚙️ service-stop     ## Stop input-remapper service
enable:   ⚙️ service-enable   ## Enable input-remapper service
disable:  ⚙️ service-disable  ## Disable input-remapper service
status:   ⚙️ service-status   ## Show status of input-remapper service
autoload: ⚙️  ## Reload input-remapper autoload mappings
	input-remapper-control --command autoload

reload: ⚙️  ## Reload input-remapper service
	@echo "Reloading input-remapper service..."
	sudo systemctl daemon-reload
	$(MAKE) restart

service-%: ⚙️
	sudo systemctl $* $(services)

diff: ⚙️  ## Show diff of input-remapper bindings
	@echo "Mapping differences:"
	@diff --color -u macstyle.json "$(PRESET)/macstyle.json" || true

info: ⚙️ vars  ## Show info about input-remapper bindings
	# Input Remapper Bindings Info:
	# Config files:
	@tree "$(PREFIX)"
	# Autoload mappings:
	# $(autoload)
	# Active mappings:
	# $(active)

show: ⚙️ info  ## Show current autoload preset
	$(goremapper) -get-preset macstyle

test: ⚙️ build  ## Run goremapper tests
	go test ./goremapper/...
