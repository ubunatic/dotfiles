
if test -e $DOTFILES/apps/go && type go >/dev/null; then
  # TODO: add a step to build them once
  for app in $DOTFILES/apps/go/*; do
    if   test -e "$app/main.go"
    then alias $(basename $app)="go run $app/main.go"
    elif test -e "$app/cmd/main.go"
    then alias $(basename $app)="go run $app/cmd/main.go"
    fi
  done
fi
