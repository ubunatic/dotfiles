# shellcheck disable=SC2155,SC2046

DOTFILES_MUST_BUILD_APPS=

dotapps-find() {
    find "$DOTFILES/apps/go" -maxdepth 1 -mindepth 1 -type d 2>/dev/null
}

dotapps-names() {
    local dir
    for dir in $(dotapps-find); do
        basename "$dir"
    done
}

dotapps-build-app() {
    local app=$(basename "$1")         # app name is the last part of the path
    local dst="$DOTFILES/bin/$app"     # destination binary
    local src="$DOTFILES/apps/go/$app" # source dir

    if test -e "$DOTFILES/bin/$app" && test -z "$DOTFILES_MUST_BUILD_APPS"
    then return 0  # already built
    fi

    (
        cd "$src" || return 1  # cannot cd to the app directory

        if test -n "$DOTFILES_RUN_APP_TESTS"
        then go test ./... || return 1
        fi

        # build the first main app that we can find
        for f in ./main.go ./cmd/main.go ./$app.go ./cmd/$app.go; do
            test -e "$f" || continue
            go build -o "$dst" "$f"
            return $?
        done >/dev/stderr

        return 0  # no buildable file found, assuming package
    )
}

dotapps-build() {
    for app in $(dotapps-find); do
        dotapps-build-app "$app"
    done
}

dotapps-rebuild() {
    dotapps-clean
    dotapps-test
}

dotapps-test() {
    DOTFILES_MUST_BUILD_APPS=1 DOTFILES_RUN_APP_TESTS=1 dotapps-build
}

dotapps-clean() {(
    for app in $(dotapps-names); do
        rm -f "$DOTFILES/bin/$app"
    done
)}

dotapps-usage(){
    cat <<-EOF
Usage: dotapps [COMMAND...]

Commands:
    clean        remove previously built binaries
    build        build binaries
    test         run app/package tests
    rebuild      build binaries and run tests
    names        print names of known dotapps
    find         find source paths of known dotapps
    help         show this help

EOF
}

dotapps() {
    if test $# -eq 0
    then dotapps-usage; return 1
    fi
    for cmd in "$@"; do case $cmd in
    (clean|build|test|rebuild) "dotapps-$cmd" || return 1 ;;
    (names|find)               "dotapps-$cmd" || return 1 ;;
    (usage|help|-h|--help)     "dotapps-usage";  return 1 ;;
    (*)                        echo "unsupported dotapps command: $cmd"; return 1;;
    esac; done
}

dotfiles-testdotapps() {
    local err
    for cmd in clean test build names find; do
        dotfiles-testcommand "dotapps-$cmd"
    done
    return $err
}

if test -e "$DOTFILES/apps/go" && type go >/dev/null; then
    if mkdir -p "$DOTFILES/bin" && dotapps build
    then dbg "dotapps loaded (exit=$?)"
    else dbg "dotapps failed (exit=$?)"
    fi
    unalias $(dotapps names) 2>/dev/null
fi

true  # clean source return