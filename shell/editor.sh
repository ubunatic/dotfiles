if test -z "$EDITOR" && type -a nvim > /dev/null; then
    alias vim=nvim
    export EDITOR=nvim
fi
