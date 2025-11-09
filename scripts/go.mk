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

# variables that can be set immediately after including this file
project         := $(notdir $(CURDIR))
main            := $(project).go
binary          := bin/$(project)
binary_args     := --help
source_patterns := *.go go.* *.mk Makefile
source_cmd      := find . -name "$(main)" $(foreach p,$(source_patterns),-o -name "$(p)")

# dynamically vars (use '=', not ':=')
# dynamically read the list of source files (everytime this variable is used)
sources = $(shell $(source_cmd))

# add Go tarets to common and targets
all:       go-build
default:   go-build
test:      go-test
clean:     go-clean
vars:      go-vars
lint:      go-lint
generate:  go-generate
install:   go-install
update:    go-update

## Go Build

go-build:     ⚙️ $(binary)       ## Build the project binary
$(binary): $(sources); go build -o $@ $(main)

go-test: ⚙️ build                ## Run tests (with race detection)
	go test -race ./...

go-debug: ⚙️ build               ## Run tests in verbose mode
	go test -v -race ./...

go-run: ⚙️ build                 ## Build and run the binary with args: $(binary_args)
	$(binary) $(binary_args)

go-clean: ⚙️                     ## Clean build files
	rm -f $(binary)

## Advanced Go Targets

go-generate: ⚙️                  ## Run Go code generation
	go generate .
go-install:   ⚙️ build           ## Build and install the binary
	go install .
go-update: ⚙️                    ## Update dependencies
	go get -u
go-tag: ⚙️                       ## Create a new git tag
	# not implemented
go-docs: ⚙️                      ## Generate documentation
	# not implemented
go-precommit: ⚙️                 ## Run pre-commit checks
	# not implemented

## Advanced Go Testing Targets

go-lint: ⚙️                      ## Run linters
	# not implemented
go-cover: ⚙️                     ## Run test coverage
	# not implemented
go-vet: ⚙️                       ## Run go vet
	# not implemented
go-bench: ⚙️                     ## Run benchmarks
	# not implemented

## Help and Debug Targets

go-vars: ⚙️  ## Show Makefile variables
	# project  $(project)
	# main:    $(main)
	# binary:  $(binary)
	# sources: $(sources)
	#
	# source_patterns: $(source_patterns)
	# source_cmd:      $(source_cmd)
