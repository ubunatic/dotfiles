
# AI Assistant Notes
# ------------------
# The funcs in this file must work in Bash and Zsh.
# Always use `test`, never `[` or `[[`.

# tmux-setup: link the dotfiles tmux config to ~/.tmux.conf
tmux-setup() {
    local src="${DOTFILES}/config/tmux.conf"
    local dst="$HOME/.tmux.conf"
    if test -L "$dst"
    then echo "tmux config already linked: $dst -> $(readlink "$dst")"
    elif test -e "$dst" &&
         test "$1" != "--force"
    then echo "tmux config exists but is not a symlink: $dst"
         echo "run 'tmux-setup --force' to replace it"
    else ln -sf "$src" "$dst" &&
         echo "tmux config linked: $dst -> $src"
    fi
}

# tmux-autostart: attach to or create a session named after the current directory.
# Call this from ~/.userrc to opt in to auto-starting tmux on shell login.
tmux-autostart() {
    if test -z "$TMUX" &&
       test -n "$PS1"
    then tmux new-session -A -s "$(basename "$PWD")"
    fi
}
