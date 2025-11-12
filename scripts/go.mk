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
go_project_dir  ?= $(CURDIR)
go_project      ?= $(notdir $(go_project_dir))
go              ?= cd $(go_project_dir) && go
gotestsum	    ?= cd $(go_project_dir) && gotestsum --format-icons=hivis --junitfile $(CURDIR)/test-report.xml
go_main         ?= $(shell \
	cd $(go_project_dir); \
	for f in cmd/$(go_project)/main.go cmd/$(go_project).go main.go $(go_project).go; \
	do if test -f "$$f"; then echo "$$f"; exit 0; fi; \
	done; echo "." \
)
go_binary       ?= $(CURDIR)/bin/$(go_project)
go_binary_args  ?= --help
go_source_patterns ?= *.go go.* *.mk
go_source_cmd      ?= find . -wholename ./Makefile -o -name "$(go_main)" $(foreach p,$(go_source_patterns),-o -name '$(p)')

# dynamically vars (use '=', not ':=')
# dynamically read the list of source files (everytime this variable is used)
go_sources ?= $(shell $(go_source_cmd))

go_testargs ?= -race ./...

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
build:     go-build

## Go Build

go-build: ⚙️ $(go_binary)        ## Build the project binary
$(go_binary): $(go_sources)
	$(go) build -o $@ $(go_main)

go-test: ⚙️ go-build             ## Run tests (with race detection)
	$(go) test $(go_testargs)

go-testsum: ⚙️ go-build          ## Run tests with test summary
	go install gotest.tools/gotestsum@latest
	$(gotestsum) -- $(go_testargs)

go-debug: ⚙️ go-build            ## Run tests in verbose mode
	$(go) test -v $(go_testargs)

go-run: ⚙️ go-build              ## Build and run the binary with args: $(go_binary_args)
	$(go_binary) $(go_binary_args)

go-clean: ⚙️                     ## Clean build files
	rm -f $(go_binary)

## Advanced Go Targets

go-generate: ⚙️                  ## Run Go code generation
	$(go) generate .
go-install:   ⚙️ go-build        ## Build and install the binary
	$(go) install .
go-update: ⚙️                    ## Update dependencies
	$(go) get -u
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
	# project  $(go_project)
	# main:    $(go_main)
	# binary:  $(go_binary)
	# sources: $(go_sources)
	#
	# source_patterns: $(go_source_patterns)
	# source_cmd:      $(go_source_cmd)
