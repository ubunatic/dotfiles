# Random collection of currently used env vars.
# Highly system-specific and unstable --> Do not copy, try to build your own!

sync_input_mapper_config() {
    file="$(find $HOME/.config/input-remapper -name 'Mac Bindings.json')"
    if test -e "$DOTFILES" -a -e "$file"
    then cp -u "$file" "$DOTFILES/config/input-mapper-mac-bindings.json"
    else return
    fi
    log "synced '$file' to $DOTFILES/config"
}


restore_input_mapper_config() {
    file="$DOTFILES/config/input-mapper-mac-bindings.json"
    trg="$1"
    if test -z "$trg"
    then echo "usage: restore_input_mapper_config TARGET_DIR"; return 1;
    fi

    if test -e "$trg" -a -e "$file"
    then cp -u "$file" "$trg/Mac Bindings.json"
    else return
    fi
    log "synced '$file' to '$trg/'"
}
