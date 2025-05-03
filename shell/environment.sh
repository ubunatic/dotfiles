# shellcheck disable=SC2155

# override these vars in your .userrc

export APPS="${APPS:-"$(dotfiles-appsdir)"}"

if test -z "$SYSTEM_UNAME"
then export SYSTEM_UNAME="$(uname 2> /dev/null || true)"
fi

# find or create local Apps dir
dotfiles-appsdir() {
    local d
    for d in "$HOME/Apps" "$HOME/apps" "$HOME/Applications" "$HOME/.local" "$HOME/.var"; do
        test -d "$d" && echo "$d" && return
    done
    # fallback to ~/.local and also create it if needed
    mkdir -p "$HOME/.local" 2>/dev/null
    echo "$HOME/.local"
}

dotfiles-testenv() {
    local apps_dir="$(dotfiles-appsdir)"
    log "ensuring that APPS='$apps_dir' dir is present"
    test -d "$($apps_dir)"
    if test -e "$apps_dir"
    then log "OK found: $apps_dir"
    else err "ERR not found: $apps_dir"
    fi
}
