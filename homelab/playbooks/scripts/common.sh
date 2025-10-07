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

here="$(cd "$__dir__" && pwd -P)"
uname="$(uname -s)"

ismac()   { test "$uname" = "Darwin"; }
islinux() { test "$uname" = "Linux";  }

if ismac
then source "$here/secret-tool.macos.sh"
fi

run() {
    if "$@"
    then ok  "'$*' completed successfully."
    else err "'$*' failed."
         return 1
    fi
}
