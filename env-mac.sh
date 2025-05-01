# Random collection of currently used env vars.
# Highly system-specific and unstable --> Do not copy, try to build your own!

# shellcheck disable=SC2155

if type tty > /dev/null
then export GPG_TTY="$(tty)"
fi

if test -e "$HOMEBREW_PREFIX/opt/openjdk@11"
then
    export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@11"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openjdk@11/include"
fi

gh-last-service-push() {
    if test -z "$1"
    then err "no service name defined as arg1"; return 1
    fi
    local service="$1"; shift
    log "using arg1 as service name: '$service', remaining gh-args: '$*'"
    gh-last-build-logs -w "Build services" "$@" | grep -o "docker push.*$service.*"
}

find-in-files() {
    local pattern="$1"; shift
    local grep_pattern="${pattern//./\\.}" match="" f="" found=0
    for f in "$@"; do
        match="$(grep -E "$grep_pattern" "$f")"
        if test $? -eq 0; then
            (( found++ ))
            echo -n "$(tput setaf 2)$f$(tput sgr0): "
            echo "$match" | grep --color -E "$grep_pattern";
        fi
    done > /dev/stderr
    echo "$found"
    test "$found" -gt 0
}

replace-in-files() {
    local search="$1" replace="$2"
    if test -z "$search";  then err "search must be set";  return 1; fi
    if test -z "$replace"; then err "replace must be set"; return 1; fi
    if test $# -lt 3;      then err "no files given";      return 1; fi
    shift 2;

    log "finding matches"
    found="$(find-in-files "$search" "$@")"
    log "found search value in $found files"

    local sed_pattern="s/${search//./\\.}/$replace/g" found=0
    if ask "run sed -i -E \"$sed_pattern\" on all the given the files: $*?"
    then
        log OK
        log "edit files in-place with sed using 's/$sed_pattern/$replace/g'"
        local ok=0
        sed -i "" -E -e "$sed_pattern" "$@" || ok=1
        log "validating results"
        found="$(find-in-files "$replace" "$@")"
        log "found replace value in $found files"
        return $ok
    else log aborted; return 1
    fi
}

export CONFLUENT_HOME=$APPS/confluent/confluent-7.0.1
if test -e "$CONFLUENT_HOME" && test -n "$ZSH_VERSION"
then
    export CONFLUENT_CURRENT=$HOME/.confluent
    if ! type confluent > /dev/null
    then export PATH=$PATH:$CONFLUENT_HOME/bin
    fi
    if test -n "$ZSH_VERSION"; then
        mkdir -p "$HOME/.oh-my-zsh/completions"
        confluent completion zsh > "$HOME/.oh-my-zsh/completions/_confluent"
        autoload -U compinit && compinit
    fi
fi

PATH_PATHS="
$HOMEBREW_PREFIX/opt/swift/bin
$HOMEBREW_PREFIX/opt/libpq/bin
$APPS/wrapped/bin
$APPS/bin
$HOME/bin
$APPS/platform-tools
$HOME/platform-tools
"

for p in $(echo "$PATH_PATHS"); do
    if test -d "$p"
    then export PATH="$p:$PATH"
    fi
done

if test -d "$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig"
then export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig"
fi
