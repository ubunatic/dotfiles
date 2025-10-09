set -o pipefail

stderr()  { echo "$@" >/dev/stderr; }
stdout()  { echo "$@" >/dev/stdout; }

ok()    { stderr "✅ $*"; }
err()   { stderr "❌ $*"; }
error() { stderr "❌ $*"; }
wrn()   { stderr "⚠️  $*"; }
warn()  { stderr "⚠️  $*"; }
inf()   { stderr "ℹ️  $*"; }
log()   { stderr "➡️  $*"; }
txt()   { stderr "$@"; }

__file__="${BASH_SOURCE:-$0}"
__dir__="$(dirname "$__file__")"
hascommon() { true; }

here="$(cd "$__dir__" && pwd -P)"
uname="$(uname -s)"

ismac()     { test "$uname" = "Darwin"; }
islinux()   { test "$uname" = "Linux";  }

vars() {
    echo "__file__    = $__file__"
    echo "__dir__     = $__dir__"
    echo "here        = $here"
    echo "uname       = $uname"
}

source "$here/secret-tool.sh"

run() {
    if "$@"
    then ok  "'$*' completed successfully."
    else err "'$*' failed."
         return 1
    fi
}
