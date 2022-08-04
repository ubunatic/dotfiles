# also see ../config/starship.toml

if type starship >/dev/null; then
    if   test -n "$ZSH_VERSION";  then eval "$(starship init zsh)"
    elif test -n "$BASH_VERSION"; then eval "$(starship init bash)"
    else # add more shells here
    fi
fi || true
