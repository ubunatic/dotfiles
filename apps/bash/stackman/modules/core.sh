#!/usr/big/env bash

log() { echo "INF $*" >/dev/stderr; }
err() { echo "ERR $*" >/dev/stderr; }

confirm() {
    local key=""
    if test "$confirm" = "ask"
    then
        echo -n "run command: '$*' at $remote_addr? [y]es [s]kip [a]bort: " >/dev/stderr
        read -r key
        case "$key" in
        (Y|y|yes)        log "command confirmed"; echo "ok" ;;
        (S|s|skip)       log "command skipped";   echo "skip" ;;
        (N|n|no|a|abort) log "command aborted";   echo "abort" ;;
        esac
    fi
}

shudo() {
    case "$(confirm "$*")" in
    (ok);; (skip) return 0;; (*) return 1;;
    esac

    case "$local" in
    (local) log "running command locally (sudo): '$*'"
            sudo "$@" ;;
    (user)  log "running command locally (user mode): '$*'"
            "$@" ;;
    (false) log "running command at $remote_addr (sudo): '$*'"
            ssh "$remote_addr" sudo "$@" ;;
    (*)     err "invalid local mode: '$local'"; exit 1
            ;;
    esac
}

bush() { shudo "bash -c '$*'"; }

copy() {
    case "$(confirm "scp '$1' '$remote_addr:$2'")" in
    (ok);; (skip) return 0;; (*) return 1;;
    esac
    local tmp
    tmp="$(ssh "$remote_addr" "mktemp /tmp/sshcopy.XXXXXXXXXX")" &&
    log "uploading file $1 as $remote_addr:$tmp" &&
    scp "$1" "$remote_addr:$tmp" &&
    log "copying as super user file $tmp to $2" &&
    ssh "$remote_addr" sudo cp "$tmp" "$2"
}

catfile() {
    local tmp_file
    tmp_file="$(mktemp echotmp.XXXXXXXXXX)" &&
    cat > "$tmp_file" &&
    echo "$tmp_file"
}

echofile() { echo "$@" | catfile; }
execho()   { echo "$*"; "$@"; }

get-key() { echo "$*" | grep -o -E   '^[a-zA-Z0-9_]+';     }
get-val() { echo "$*" | sed     -e 's|^[a-zA-Z0-9_]*=||g'; }
get-user(){ echo "$*" | grep -o -E   '^[^@]+';     }
get-host(){ echo "$*" | sed     -e 's|^[^@]*@||g'; }
