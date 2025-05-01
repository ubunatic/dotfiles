# shellcheck disable=SC2155

# set to a non-empty value to force building all go apps
DOTFILES_MUST_BUILD_APPS=

dotapp-build-go-app() {
    local dir="$1"                  # app directory, including the app name
    local app=$(basename "$dir")    # app name is the last part of the path
    local dst="$DOTFILES/bin/$app"  # destination binary

    if test -e "$DOTFILES/bin/$app" && test -z "$DOTFILES_MUST_BUILD_APPS"
    then return 0  # already built
    fi

    (
      cd "$dir" || return 1  # cannot cd to the app directory

      for f in ./main.go ./cmd/main.go ./$app.go ./cmd/$app.go; do
          test -e "$f" || continue
          if test -n "$DOTFILES_RUN_APP_TESTS"
          then go test ./... && go build -o "$dst" "$f" && return 0
          else                  go build -o "$dst" "$f" && return 0
          fi
      done >/dev/stderr

      return 1  # no buildable file found
    )
}

dotapp-rebuild-all() {
    for app in "$DOTFILES"/apps/go/*; do
        DOTFILES_MUST_BUILD_APPS=1 DOTFILES_RUN_APP_TESTS=1 dotapp-build-go-app "$app"
    done
}

if test -e "$DOTFILES/apps/go" && type go >/dev/null; then
  mkdir -p "$DOTFILES/bin"
  for app in "$DOTFILES"/apps/go/*; do
    dotapp-build-go-app "$app"                # build once (or always if DOTFILES_MUST_BUILD_APPS is set)
    unalias "$(basename "$app")" 2>/dev/null  # remove any alias for the app
  done
fi
