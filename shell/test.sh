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

export DOTFILES_TESTS=(
test_common
test_find
test_logging
test_env
test_go
test_gomake
test_gruboot
test_efiboot
)

test_shells() {
    log "testing bash"
    DOTFILES_AUTOTEST=1 bash -c "source '$DOTFILES/shell/userrc.sh'" &&
    log "testing zsh" &&
    DOTFILES_AUTOTEST=1 zsh -c "source '$DOTFILES/shell/userrc.sh'"
}

# shellcheck disable=SC2086
test_functions() {
    if test_runner "${DOTFILES_TESTS[@]}"
    then log "$0: all tests successful"
    else err "$0: some tests failed"
    fi
}

# manually start all tests, incl zsh and bash test
test_dotfiles() {
    test_functions &&
    test_shells
}

test_runner() {
    echo "running: $*"
    local err
    for t in "$@"; do
        echo "testing: $t"
        if "$t"
        then log "OK  $t"
        else err "ERR $t"; err=1
        fi
        shift
    done
    test -z "$err"
}

if test -n "$DOTFILES_AUTOTEST"
then test_functions
fi
