
for dir in \
    "$DOTFILES/bin" \
    "$APPS/platform-tools" \
    "$HOME/linuxbrew/.linuxbrew/bin"
do  if test -d "$dir"
    then PATH="$PATH:$dir"
    fi
done
unset dir
