# Multipass Experiments
# =====================

# Allow to connect to multipass with X support.
# You must copy the multipass rsa key from Application Support or similar
multipass-x() {
    if test -f ~/.ssh/id_rsa.multipass
    then
        mpip="$(mp info primary --format json | jq -cr '.info.primary.ipv4[0]')"
        ssh -XC -i ~/.ssh/id_rsa.multipass ubuntu@$mpip
    else
        error "~/.ssh/id_rsa.multipass not found, please copy it from the multipass installation"
    fi
}

# multipass aliases
alias mp=multipass
alias mpx=multipass-x
