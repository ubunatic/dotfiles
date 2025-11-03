# Go Makefile
#
# This is a generic file to help developing Go projects. It provides file and
# command targets for common Go dev tasks. Copy this file into your project as
# `scripts/go.mk`, customize it, and include it in your main Makefile. Or use
# as your initial Makefile and customize it as needed.
# 
# Also see `scripts/usage.mk` for getting 'usage' and 'usage-all' targets that
# will, detect the '##' comments and print help for all Makefile targets.

.PHONY: ⚙️  # make all non-file targets phony

## Sources and Binaries

project := $(notdir $(CURDIR))
main = $(project).go
binary = bin/$(project)
binary_args = --help
source_patterns = *.go go.* *.mk Makefile
source_cmd = find . -name $(main) $(foreach p,$(source_patterns),-o -name "$(p)")
sources = $(shell $(source_cmd))

## Default Build Target

all:       ⚙️ build                             ## Default: build the project binary
build:     ⚙️ $(binary)                         ## Build the project binary
$(binary): $(sources); go build -o $@ $(main)

## Common Go Build Targets

test: ⚙️ build                ## Run tests (with race detection)
	go test -race ./...

debug: ⚙️ build               ## Run tests in verbose mode
	go test -v -race ./...

run: ⚙️ build                 ## Build and run the binary with args: $(binary_args)
	$(binary) $(binary_args)

clean: ⚙️                     ## Clean build files
	rm -f $(binary)

## Advanced Go Targets

generate: ⚙️                  ## Run Go code generation
	go generate .
install:   ⚙️ build           ## Build and install the binary
	go install .
update: ⚙️                    ## Update dependencies
	go get -u
tag: ⚙️                       ## Create a new git tag
	# not implemented
docs: ⚙️                      ## Generate documentation
	# not implemented
precommit: ⚙️                 ## Run pre-commit checks
	# not implemented

## Advanced Go Testing Targets

lint: ⚙️                      ## Run linters
	# not implemented
cover: ⚙️                     ## Run test coverage
	# not implemented
vet: ⚙️                       ## Run go vet
	# not implemented
bench: ⚙️                     ## Run benchmarks
	# not implemented

## Help and Debug Targets

vars: ⚙️  ## Show Makefile variables
	# project  $(project)
	# main:    $(main)
	# binary:  $(binary)
	# sources: $(sources)
	#
	# source_patterns: $(source_patterns)
	# source_cmd:      $(source_cmd)
