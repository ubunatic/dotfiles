# Logging and File Search
# =======================
#
# Simple wrappers around common commands.
# Please `source` this file first before using the other scripts.
#

err() {
  local code=$?
  echo -n "ERR: " 1>&2; echo "$@" 1>&2;
  return $code
}
inf() {
  local code=$?
  echo -n "INF: " 1>&2; echo "$@" 1>&2;
  return $code
}
dbg() {
  local code=$?
  if test -n "$DOTFILES_DEBUG"
  then echo -n "DBG: " 1>&2; echo "$@" 1>&2;
  fi
  return $code
}

fail() { err "$@"; false; }

ff() { find . -name "$*"; }
fz() { find . -name "*$**"; }

prompt() {
  echo -n "$@"
  echo -n ":"
}

ask() {
  echo -n "$@"
  echo -n " (y/N): "
  read -r answer && test "$answer" = "y"
}

# finds a real command on the path
find_command() {
  if cmd=$(type -p "$1" | grep -o '/.*')
  then echo "$cmd" && return 0  # return the path to the command
  else echo "$1"   && return 1  # return the command name as is
  fi
}

# upwards file search
find_up() {
  dir="$(pwd)"
  while true; do
    test -e "$dir/$1" && echo "$dir/$1" && return 0 ||
    test "$dir" = "/"                   && return 1 ||
    dir="$(dirname "$dir")"
  done
}

# emulate make $(shell ...) command
shell() { bash -c "$*"; }

{
  unalias error
  unalias debug
  unalias log
} 2> /dev/null

error() { err "$@"; }
debug() { dbg "$@"; }
log()   { inf "$@"; }

dotfiles-testlogging() {
    log "testing log command via their aliases"
    error "ERROR Test (this ERR log is expected)" &&
    debug "DEBUG Test" &&
    log "LOG Test"
}

dotfiles-testfind() {(
    log "testing file find commands ff and fz"
    cd "$DOTFILES" &&
    ff "shell"  | grep -q ./shell &&
    fz "hell"   | grep -q ./shell &&
  ! ff "hell"   | grep -q '.*'  &&
  ! fz "R4ND0M" | grep -q '.*'
)}

dotfiles-testcommon() {
  (echo "y" | ask "test" && echo "OK" || echo "NO") | grep -q "OK"
  (echo "N" | ask "test" && echo "OK" || echo "NO") | grep -q "NO"
}
