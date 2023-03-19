# Logging and File Search
# =======================
#
# Simple wrappers around common commands.
# Please `source` this file first before using the other scripts.
#

err() { echo -n "ERR: " 1>&2; echo "$@" 1>&2; }
inf() { echo -n "INF: " 1>&2; echo "$@" 1>&2; }
dbg() {
  if test -n "$DEBUG"
  then echo -n "DBG: " 1>&2; echo "$@" 1>&2;
  fi
}

ff() { find . -name "$@"; }
fz() { find . -name "*$@*"; }

ask() {
  echo -n "$@"
  echo -n " (y/N): "
  read answer && test "$answer" = "y"
}

alias error=err
alias debug=dbg
alias log=inf

test_logging() {
    log "testing log command via their aliases"
    error "ERROR Test (this ERR log is expected)" &&
    debug "DEBUG Test" &&
    log "LOG Test"
}

test_find() {(
    log "testing file find commands ff and fz"
    cd "$DOTFILES" &&
    ff "shell"  | grep -q ./shell &&
    fz "hell"   | grep -q ./shell &&
  ! ff "hell"   | grep -q '.*'  &&
  ! fz "R4ND0M" | grep -q '.*'
)}
