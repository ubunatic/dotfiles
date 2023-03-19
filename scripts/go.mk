# (!) Generated File (!)
# Consider making changes in the main Makefile instead.
#
# This is a generic file to help developing Go projects.
# It provides file and command targets for common Go dev tasks.

# Sources and Binaries
# --------------------
project := $(notdir $(shell pwd))
main = $(project).go
binary = bin/$(project)
sources = $(shell find . -name '*.go') $(wildcard go.*) $(main)

# Default Build Target
# --------------------
.PHONY: all build
all:       build
build:     $(binary)
$(binary): $(sources); go build -o $@ $(main)

# Common Go Build Targets
# -----------------------
.PHONY: test debug install run clean
test:    build; go test -race ./...
debug:   build; go test -v -race ./...
install: build; go install .
run:     build; $(binary)
clean:        ; rm -f $(binary)

# Help and Debug Targets
# ----------------------
.PHONY: vars usage
vars:
	# project  $(project)
	# main:    $(main)
	# binary:  $(binary)
	# sources: $(sources)

usage:
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
