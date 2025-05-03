# Tests
# =====
#
# Add tests into DOTFILES_TESTS.
# These test functions are called by `test_dotfiles`,
# which is called on startup if DOTFILES_AUTOTEST is set.
#
# Use && and || in your tests.
# Do not trust `set -e` or other unsafe measures.
#

export DOTFILES_TESTS="
dotfiles-testcommon
dotfiles-testfind
dotfiles-testlogging
dotfiles-testenv
dotfiles-testgo
dotfiles-testgomake
dotfiles-testgruboot
dotfiles-testefiboot
dotfiles-testcolors
"

dotfiles-testnames() {
    echo $DOTFILES_TESTS
}

dotfiles-testshells() {
    log "testing bash"
    DOTFILES_AUTOTEST=1 bash -c "source '$DOTFILES/shell/userrc.sh'" &&
    log "testing zsh" &&
    DOTFILES_AUTOTEST=1 zsh -c "source '$DOTFILES/shell/userrc.sh'"
}

# shellcheck disable=SC2086
dotfiles-testfunctions() {
    if dotfiles-testcommands $(dotfiles-testnames)
    then log "$0: function tests successful"
    else err "$0: function tests failed"
    fi
}

# manually start all tests, incl zsh and bash test
dotfiles-testall() {
    if dotfiles-testfunctions &&
       dotfiles-testdotapps &&
       dotfiles-testshells
    then log "$0: tests successful"
    else err "$0: tests failed"; return 1
    fi
}

dotfiles-testcommands() {
    local err
    for t in "$@"; do
        dotfiles-testcommand "$t"
        test $? -eq 0 || err=1
    done
    test -z "$err"
}

dotfiles-testcommand() {
    local cmd out code
    DEBUG=1
    cmd="$*"
    dbg -n "testing '$cmd' 🧪"
    out="$($* 2>&1)"
    code=$?
    echo -ne "\r" 2>/dev/stderr
    if test "$code" -eq 0
    then dbg "testing '$cmd' ✅ code=$code"
    else dbg "testing '$cmd' ❌ code=$code"
        echo "$out" >/dev/stderr
        dbg "dotapp '$cmd': ❌ code=$code"
    fi
    return $code
}

if test -n "$DOTFILES_AUTOTEST"
then dotfiles-testfunctions
fi
