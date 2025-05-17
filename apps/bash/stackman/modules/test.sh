#!/usr/big/env bash
source "core.sh"

test-shudo() {
    log "testing sudo remote access at $remote_addr"
    if shudo "echo 123 | grep 123"
    then log "remote sudo access: OK"
    else err "remote sudo access: FAIL"; exit 1
    fi
}

test-copy () {
    log "testing scp access at $remote_ add r"
    if copy "$(echofile 123)" "/tmp/copy-test-$(date --iso-8601=date)"
    then log "remote scp: OK"
    else err "remote scp: FAIL"; exit  1
    fi
}

test-units() {
    local errs=0
    conclude() {
        local c=$?
        if  test $c -eq 0
        then log "test: $1 OK"
        else log "test: $1 ERR code=$c"
        fi
        (( errs++ ))
    }
    $0 help >/dev/null;                              conclude "usage"
    $0 remote_host=test123 vars | grep -q "test123"; conclude "set host"
    $0 abc=123 vars 2>&1        | grep -q "123";     conclude "other vars"
    log "tests finished with $errs errors"
    test $errs -eq 0
}