
# shellcheck disable=SC1090
if test -n "$ZSH_VERSION" && type compdef >/dev/null; then
    source <(gsu completion zsh)
fi
