set -o errexit
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

here="$(dirname "$0")"

run() {
    if "$@"
    then ok  "'$*' completed successfully."
    else err "'$*' failed."
         exit 1
    fi
}