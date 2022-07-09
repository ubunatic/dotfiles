# Random collection of currently used env vars.
# Highly system-specific and unstable --> Do not copy, try to build your own!

if type tty > /dev/null
then export GPG_TTY="$(tty)"
fi

if test -e $HOMEBREW_PREFIX/opt/openjdk@11
then
    export JAVA_HOME=$HOMEBREW_PREFIX/opt/openjdk@11
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openjdk@11/include"
fi

export CONFLUENT_HOME=$APPS/confluent/confluent-7.0.1
if test -e "$CONFLUENT_HOME" && test -n "$ZSH_VERSION"
then
    export CONFLUENT_CURRENT=$HOME/.confluent
    if ! type confluent > /dev/null
    then export PATH=$PATH:$CONFLUENT_HOME/bin
    fi
    if test -n "$ZSH_VERSION"; then
        mkdir -p $HOME/.oh-my-zsh/completions
        confluent completion zsh > $HOME/.oh-my-zsh/completions/_confluent
        autoload -U compinit && compinit
    fi
fi

PATH_PATHS="
$HOMEBREW_PREFIX/opt/swift/bin
$HOMEBREW_PREFIX/opt/libpq/bin
$APPS/wrapped/bin
"

for p in $PATH_PATHS; do
    if test -d
    then export PATH="$p:$PATH"
    fi
done

if test -d "$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig"
then export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig"
fi
