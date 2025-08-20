#!/usr/bin/env bash
# install bash apps

err()  { echo "ERR: $*" >/dev/stderr; }
warn() { echo "WRN: $*" >/dev/stderr; }
log()  { echo "INF: $*" >/dev/stderr; }

# single file apps
singlefile_apps=(
    mclog:mclog/mclog.sh
    dtest:dtest/docker-test.sh
)

make_bin_dir() {
    if test -d "$DOTFILES/bin"
    then return 0  # already exists
    fi

    if mkdir -p "$DOTFILES/bin"
    then log "created bin directory at $DOTFILES/bin"
    else
        err "failed to create bin directory"
        exit 1
    fi
}

make_singlefile_app() {
    local name="$1" path="$2"
    if $reinstall
    then
        if rm -f "$DOTFILES/bin/$name"
        then log "removed existing $name binary/symlink"
        else err "failed to remove existing $name binary/symlink"; return 1
        fi
    fi

    if test -e "$DOTFILES/bin/$name"
    then return 0  # already installed
    fi

    if ln -s "$DOTFILES/apps/bash/$path" "$DOTFILES/bin/$name"
    then log "created symlink for $name at $DOTFILES/bin/$name"
    else err "failed to create symlink for $name"; return 1
    fi

    if command -v "$name" >/dev/null 2>&1
    then log  "app found on PATH, run it with: $name"
    else warn "failed to find $name in PATH, please ensure $DOTFILES/bin is in your PATH"
    fi
}

make_apps() {
    for kv in "${singlefile_apps[@]}"; do
        IFS=':' read -r name path <<< "$kv"  # IFS is the internal field separator, <<< is used to read from a string
        make_singlefile_app "$name" "$path"
    done
}

reinstall=false
for arg in "$@"; do
    case "$arg" in
    --reinstall|-r) reinstall=true;;
    *)              err "unknown argument: $arg"; exit 1 ;;
    esac
done

if test -n "$DOTFILES"
then
    make_bin_dir && make_apps
else
    err "DOTFILES environment variable is not set"
    exit 1
fi
