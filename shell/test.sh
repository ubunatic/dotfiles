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
test_find
test_logging
test_env
test_go
test_gomake
test_boot
test_grub
"

test_shells() {
    log "testing bash"
    DOTFILES_AUTOTEST=1 bash -c "source '$DOTFILES/shell/userrc.sh'"
    log "testing zsh"
    DOTFILES_AUTOTEST=1 zsh -c "source '$DOTFILES/shell/userrc.sh'"
}

test_functions() {
    test_runner $DOTFILES_TESTS &&
    log "$0: function testing successful" ||
    err "$0: functions testing failed"
}

# manually start all tests, incl zsh and bash test
test_dotfiles() {
    test_functions &&
    test_shells
}

test_runner() {
    echo "running: $*"
    local err=
    for t in $(echo "$*"); do
        echo "testing: $t"
        if "$t"
        then log "OK  $t"
        else err "ERR $t"; err=1
        fi
    done
    test -z "$err"
}

if test -n "$DOTFILES_AUTOTEST"
then test_functions
fi
