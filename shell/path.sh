
# add Android SDK platform tools to path
if test -d "$SYSTEM_APPS/platform-tools"; then
    PATH="$SYSTEM_APPS/platform-tools:$PATH"
fi

if test -d "$DOTFILES/bin"; then
    PATH="$DOTFILES/bin:$PATH"
fi
