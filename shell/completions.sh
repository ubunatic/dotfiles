
# shellcheck disable=SC1090
if test -n "$ZSH_VERSION" && type compdef >/dev/null; then
    if type gsu >/dev/null
    then source <(gsu completion zsh)
    fi
fi

# also see ../config/starship.toml
if test -n "$USE_STARSHIP" && type starship >/dev/null; then
    if   test -n "$ZSH_VERSION";  then eval "$(starship init zsh)"
    elif test -n "$BASH_VERSION"; then eval "$(starship init bash)"
    fi
fi
