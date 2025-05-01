# Basic/Zsh DotFile Loader
# ========================
# Provides most basic setup to work with gcloud, Python, and more.
# Add some utility functions to be used in micro libs for daily work.
# Load all desired dotfiles here by `source`ing them, as shown below.

#shellcheck disable=SC1091
if test -e "$DOTFILES"; then
source "$DOTFILES/shell/environment.sh"  # load this first, to setup basic file location info
source "$DOTFILES/shell/common.sh"       # load this second to load logging funcs needed by other scripts
source "$DOTFILES/shell/path.sh"
source "$DOTFILES/shell/config.sh"
source "$DOTFILES/shell/aliases.sh"
source "$DOTFILES/shell/editor.sh"
source "$DOTFILES/shell/system.sh"
source "$DOTFILES/shell/git.sh"
source "$DOTFILES/shell/gh.sh"
source "$DOTFILES/shell/py.sh"
source "$DOTFILES/shell/go.sh"
source "$DOTFILES/shell/gomake.sh"
source "$DOTFILES/shell/swift.sh"
source "$DOTFILES/shell/gcloud.sh"
source "$DOTFILES/shell/starship.sh"
source "$DOTFILES/shell/efiboot.sh"
source "$DOTFILES/shell/grub.sh"
source "$DOTFILES/shell/prompt.sh"
source "$DOTFILES/shell/apps.sh"
source "$DOTFILES/shell/completions.sh"
source "$DOTFILES/shell/test.sh"         # test.sh should be last to allow for autotesting
fi
