
# add Android SDK platform tools to path
if test -d "$APPS/platform-tools"; then
    PATH="$APPS/platform-tools:$PATH"
fi

if test -d "$DOTFILES/bin"; then
    PATH="$DOTFILES/bin:$PATH"
fi
