# Go Setup
# ========

gopath() {
    if type go 1>/dev/null 2>/dev/null
    then go env GOPATH
    fi
}

export GOPATH="$(gopath)"

if test -n "$GOPATH"; then
    export PATH="$PATH:$GOPATH/bin"
    if test "$SYSTEM_UNAME" = "Darwin"; then
        # See here: https://github.com/golang/go/issues/61229#issuecomment-1988965927

        # Avoid linker warnings by using the classic linker
        # will create new warnings about the classic linker being outdated.
        # Outdated Solution:
        # export GOFLAGS="-ldflags=-extldflags=-Wl,-ld_classic"

        # Avoid linker warnings by using the internal linker:
        # export GOFLAGS="-ldflags=-linkmode=internal"

        # Avoid linker warnings by disabling warnings:
        export GOFLAGS="-ldflags=-extldflags=-Wl,-w"
    fi
fi

dotfiles-testgo() {
    test "$GOPATH" = "$(gopath)" || err "GOPATH='$GOPATH' != (go env GOPATH)='$(gopath)' not set"
}

golangci-lint() {
    local cfg="" golangci_lint=""
    golangci_lint="$(find_command golangci-lint)" &&
    if cfg=$(find_up .golangci.yml) && test "$1" = "run"
    then
        log "golangci-lint wrapper: using config $cfg"
        $golangci_lint "$@" -c "$cfg"
    else $golangci_lint "$@"
    fi
}
