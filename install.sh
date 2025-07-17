#!/usr/bin/env bash
# Simple Dotfiles Installer

here() { (cd "$(dirname "$0")" && pwd); }
here=$(here)

usage() {
    cat <<-EOF
Simple Dotfiles Installer
Usage: [zsh|bash] $0 [COMMAND]
Commands
   install        install the dotfiles from $here
   validate       show setup script in rcfiles
   -h, --help     print this help
EOF
}

userrc_script="
# dotfiles config added by '$0'
export DOTFILES='$here'
source '$here/shell/userrc.sh' || true
"

rc_script="
# userrc config added by '$0'
source ~/.userrc || true
"

install-core(){
    # create .userrc
    if test -e $HOME/.userrc
    then echo "found $HOME/.userrc"
    else touch $HOME/.userrc &&
         echo "created $HOME/.userrc"
    fi

    # add dotfiles to .userrc
    if grep -q "DOTFILES" "$HOME/.userrc"
    then echo "found 'DOTFILES' in .userrc, assuming installed"
    else echo "$userrc_script" >> "$HOME/.userrc"
    fi

    # detected shell
    if test -n "$ZSH_VERSION"
    then rcfile=~/.zshrc
    elif test -n "$BASH_VERSION"
    then rcfile=~/.bashrc
    else rcfile=~/.profile
    fi

    # install in detected shell
    if test -e $rcfile
    then echo "found main rcfile $rcfile"
    else touch $rcfile &&
         echo "created main rcfile $rcfile"
    fi

    if grep -q '.userrc' $rcfile
    then echo "found '.userrc' in $rcfile, assuming installed"
    else echo "$rc_script" >> $rcfile
    fi

    echo "dotfiles setup complete"
    echo "userrc=~/.userrc"
    echo "rcfile=$rcfile"
    echo "DOTFILES=$DOTFILES"

    echo "run source ~/.userrc to activate dotfiles in this shell session"
}

validate() {
    for f in ~/.userrc ~/.profile ~/.bashrc ~/.zshrc; do
        if test -e "$f"
        then echo "ℹ️ $f"
        else continue
        fi
        grep -E 'dotfiles|userrc' "$f"
    done
}

main() {
    case "$1" in
    (install)   install-core;;
    (validate)  validate;;
    (-h|--help) usage;;
    (*)         echo "invalid argument: $1"; usage;;
    esac
}

main "$@"
