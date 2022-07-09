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
test_shells
"

test_shells() {
    log "testing bash"
    DOTFILES_AUTOTEST= bash -c "source $HOME/.userrc"
    log "testing zsh"
    DOTFILES_AUTOTEST= zsh -c "source $HOME/.userrc"
}

test_dotfiles() {
    test_runner $DOTFILES_TESTS &&
    log "$0: testing successful" ||
    err "$0: testing failed"
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
then test_dotfiles
fi
