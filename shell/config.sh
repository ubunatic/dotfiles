# shellcheck disable=SC2155

# dotfiles-config restores or backups a config file from $DOTFILES/config to a local path.
dotfiles-config() {(
    set -o errexit
    local cmd="$1" root="$2" profile="$3"
    log "$0: cmd=$1 root='$root' profile='$profile'"

    if test -z "$cmd" -o -z "$root" -o -z "$profile"
    then err "usage: $0 backup|restore CONFIG_ROOT CONFIG_FILE"; return 1
    fi

    local file="$(basename "$profile")"
    local local_file="$root/$file"
    local remote_file="$DOTFILES/config/$file"
    local trg="" src=""

    case "$cmd" in
        ba*) src="$local_file" trg="$remote_file";;
        re*) trg="$local_file" src="$remote_file";;
        *)   err "invalid command: '$cmd'"; return 1;;
    esac

    local target_dir="$(dirname "$trg")"

    debug "DOTFILES=$DOTFILES"
    debug "src='$src'"
    debug "trg='$trg'"
    debug "target_dir='$target_dir'"

    if test -e "$DOTFILES" -a -e "$src" -a -e "$target_dir"
    then
        log "copying '$src' to '$trg'"
        cp -u "$src" "$trg"
    else
        err "some dirs/files not found"
        info "try creating the profile '$profile' first"
        return 1
    fi
    log "$0: DONE"
)}
