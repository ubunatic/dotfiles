
gomake() {
    cat "$DOTFILES/scripts/go.mk"
}

test_gomake() {
    gomake | grep "Generated File" > /dev/null
    make -n -C "$DOTFILES/scripts" -f go.mk clean vars usage > /dev/null
}
