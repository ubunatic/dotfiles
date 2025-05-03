
gomake() {
    cat "$DOTFILES/scripts/go.mk"
}

dotfiles-testgomake() {
    gomake | grep "Generated File" > /dev/null
    make -n -C "$DOTFILES/scripts" -f go.mk clean vars usage > /dev/null
}
