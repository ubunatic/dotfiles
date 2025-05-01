# shellcheck disable=SC2155

# override these vars in your .userrc

export APPS="${APPS:-$HOME/Apps}"
export APPS_UTILS="${APPS_UTILS:-$APPS}"
export SYSTEM_APPS="${SYSTEM_APPS:-$HOME/Apps}"
export SYSTEM_APPS_UTILS="${SYSTEM_APPS_UTILS:-$SYSTEM_APPS}"

if test -z "$SYSTEM_UNAME"
then export SYSTEM_UNAME="$(uname 2> /dev/null || true)"
fi

test_env() {
    log "ensuring that APPS dirs are defined"
    local err=
    for dir in "$APPS" "$APPS_UTILS" "$SYSTEM_APPS" "$SYSTEM_APPS_UTILS"; do
        if test -e "$dir"
        then log "OK  found:     $dir"
        else err "ERR not found: $dir"; err=1
        fi
    done
    test -z "$err"
}
