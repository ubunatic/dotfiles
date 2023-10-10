# Go Setup
# ========

if test -z "$GOPATH" && test -d $HOME/go/bin
then
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
fi

test_go() {
    type go &&
    test -d "$GOPATH"
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
