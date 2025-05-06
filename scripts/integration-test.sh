#!/usr/bin/env bash

export TERM="${TERM:-"xterm-256color"}"
export DOTFILES="$(pwd)"
export DEBUG=1

echo "system info"
uname --all

if echo -n "repo dir size: " && du -sh . &&
   touch -c "$DOTFILES/shell" &&
   touch -c "$DOTFILES/shell/userrc.sh"
then
   echo "found dotfiles at '$DOTFILES'"
else
    echo "dotfiles not found"
    exit 1
fi

if source "$DOTFILES/shell/userrc.sh"
then dbg "sourced dotfiles"
else echo "failed to source dotfiles"; exit 1
fi

if type go >/dev/null
then dbg "found go binary, will build go apps"
else dbg "go binaries not found, skipping go build"
    DOTFILES_SKIP_BUILD_APPS=1
fi

if type zsh >/dev/null && false
then dbg "found zsh"
else dbg "using 'echo' as fake zsh"
    zsh() {
        dbg "zsh $*  # command skipped"
    }
fi

if dotapps clean build test
then dbg "dotapps build successful"
else dbg "dotapps build failed"; exit 1
fi

if make -n -C apps/go/gsu -f ../../../scripts/go.mk
then dbg "make go successful"
else dbg "make go failed"; exit 1
fi

dotfiles-testall
