# Basic/Zsh DotFile Loader
# ========================
# Provides most basic setup to work with gcloud, Python, and more.
# Add some utility functions to be used in micro libs for daily work.
# Load all desired dotfiles here by `source`ing them, as shown below.

#shellcheck disable=SC1091
if test -e "$DOTFILES"; then
source "$DOTFILES/shell/environment.sh"
source "$DOTFILES/shell/common.sh"
for source_file in \
    environment.sh \
    common.sh \
    path.sh \
    config.sh \
    aliases.sh \
    editor.sh \
    system.sh \
    git.sh \
    gh.sh \
    py.sh \
    go.sh \
    gomake.sh \
    swift.sh \
    gcloud.sh \
    efiboot.sh \
    grub.sh \
    prompt.sh \
    apps.sh \
    docker.sh \
    proxmox.sh \
    completions.sh \
    test.sh
do
    if source "$DOTFILES/shell/$source_file"
    then dbg "sourced $source_file ✅"
    else err "failed to source $source_file ❌"
    fi
done
fi
