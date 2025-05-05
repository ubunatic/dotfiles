# Common Aliases
# ==============
#
# Also see the *.sh files for component specific aliases.
#

_GREEN=$(tput setaf 2)
_BLUE=$(tput setaf 4)
_CYAN=$(tput setaf 6)
_RED=$(tput setaf 1)
_RESET=$(tput sgr0)
_BOLD=$(tput bold)

dotfiles-testcolors() {
    local color
    for c in GREEN BLUE CYAN RED; do
        eval color="\$_$c"
        echo "regular: ${color}$c${_RESET},\tbold: ${_BOLD}${color}$c${_RESET}"
    done
}

# File system aliases
alias ll="ls -la"
alias ccd="cd"
alias cdd="cd"
alias cd..="cd .."

# Github cli aliases
alias prw='gh-prw'
alias prv='gh-prw'
alias prc='gh-prc'
alias pr='gh-prw 2> /dev/null || gh-prc'
alias release='gh-release-main'

# Git aliases
alias pull="git pull"
alias pul="git pull"
alias gss="git status --short"
alias gs="git status --short"
alias gco="git checkout"
alias goc="git checkout"
alias main="git checkout main"

alias gaa="git add --all"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpf="git push --force"
alias gcamd="git status --short && git commit --amend --no-edit --allow-empty && echo 'commit ammended'"
alias gcapf="git status --short && git commit --amend --no-edit --allow-empty && echo 'commit ammended for force push' && git push --force"
alias push="git push"
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gpsupu='git push --set-upstream "$USER" "$(git branch --show-current)"'
alias gr="gitroot"
alias cg="gitroot"
alias main="git checkout main && git pull"

unalias gsu 2>/dev/null

if test "$SYSTEM_UNAME" = "Darwin"
then alias apt="brew"
fi
