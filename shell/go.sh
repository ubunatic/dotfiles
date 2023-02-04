# Go Setup
# ========

if test -z "$GOPATH" && test -d $HOME/go/bin
then
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
fi

test_go() {
    type go &&
    test -d "$GOPATH"
}
