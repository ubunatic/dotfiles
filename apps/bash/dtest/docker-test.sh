#!/usr/bin/env bash
# Run tests in docker to simulate the CI environment.

# AI Assistant Notes
# ------------------
# The funcs in this file must work in Bash and Zsh.
# Always use `test`, never `[` or `[[`.

#shellcheck disable=SC2086

# resolve symlink to this script
this="$(realpath "$0")"
here="$(dirname "$this")"
module="$(dirname "$(go env GOMOD 2> /dev/null)")"
root="${module:-"."}"

# read external vars and set defaults
export TEST_PKG="${TEST_PKG:-"./..."}"
export TEST_FLAGS="${TEST_FLAGS:-"-v -p=1 -timeout 10m -tags unit,test"}"
export TEST_COMPOSE_FILE="${TEST_COMPOSE_FILE:-"$here/docker-compose.yml"}"

compose() {
  docker compose --file "$TEST_COMPOSE_FILE" "$@"
}

# Cleanup after docker tests
docker-cleanup() {
    echo "🧹 Cleaning up after docker tests"
    compose down
    rm -rf vendor
}

# Run tests in docker
docker-run() {
    echo "🐳 Running tests in Docker (root: $root, compose file: $TEST_COMPOSE_FILE)"

    trap docker-cleanup EXIT
    go mod tidy
    go mod vendor
    compose --project-directory "$root" up --attach testing
}

# Run tests directly
go-run() {
    echo "🧪 Running Go tests in $root with as: go test $TEST_FLAGS $TEST_PKG"

    if (cd "$root" && go test $TEST_FLAGS $TEST_PKG)
    then echo "✅ Tests passed"; return 0
    else echo "❌ Tests failed"; return 1
    fi
}

usage() {
    cat <<EOF
Usage: $0 {go-run|docker-run|cleanup}

Environment Variables:
  TEST_COMPOSE_FILE Path to the docker-compose file (default: $TEST_COMPOSE_FILE)
  TEST_PKG          Package to test (default: $TEST_PKG)
  TEST_FLAGS        Flags to pass to go test (default: $TEST_FLAGS)
EOF
}

case "$1" in
  go*)     go-run;         exit $?;;
  docker*) docker-run;     exit $?;;
  clean*)  docker-cleanup; exit 0;;
  *)       echo "Unknown command: '$1'"; usage; exit 1;;
esac
