# (!) Generated File (!)
# Consider making changes in the main Makefile instead.
#
# This is a generic file to help developing Go projects.
# It provides file and command targets for common Go dev tasks.

.PHONY: ⚙️  # make all non-file targets phony

# Sources and Binaries
# --------------------
project := $(notdir $(CURDIR))
main = $(project).go
binary = bin/$(project)
source_patterns = *.go go.* *.mk Makefile
source_cmd = find . -name $(main) $(foreach p,$(source_patterns),-o -name "$(p)")
sources = $(shell $(source_cmd))

# Default Build Target
# --------------------
all:       ⚙️ build
build:     ⚙️ $(binary)
$(binary): $(sources); go build -o $@ $(main)

# Common Go Build Targets
# -----------------------
test:    ⚙️ build; go test -race ./...
debug:   ⚙️ build; go test -v -race ./...
run:     ⚙️ build; $(binary)
clean:   ⚙️      ; rm -f $(binary)

# Advanced Go Targets
# -------------------
generate:  ⚙️      ; go generate .
install:   ⚙️ build; go install .
update:    ⚙️      ; go get -u
tag:       ⚙️      ; # not implemented
docs:      ⚙️      ; # not implemented
precommit: ⚙️      ; # not implemented

# Advanced Go Testing Targets
# ---------------------------
lint:   ⚙️ ; # not implemented
cover:  ⚙️ ; # not implemented
vet:    ⚙️ ; # not implemented
bench:  ⚙️ ; # not implemented

# Help and Debug Targets
# ----------------------
vars: ⚙️
	# project  $(project)
	# main:    $(main)
	# binary:  $(binary)
	# sources: $(sources)
	#
	# source_patterns: $(source_patterns)
	# source_cmd:      $(source_cmd)

usage: ⚙️
	# Usage: make TARGET [-n|-B]
	#
	# Targets:
	#     build     build the binary: $(binary)
	#     test      run go test
	#     debug     run go test -v
	#     run       build and runs the binary $(binary)
	#     install   run go install
	#     vars      show make vars
	#     usage     show this info
	#
	# Flags:
	#     -n        dry run, showing commands that would run
	#     -B        force build even if sources have not changed
	#
	#     Also see `make -h` for more common flags
