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

# folder switching
alias gr="gitroot"
alias cg="gitroot"

# Git aliases
alias pull="git pull"
alias pul="git pull"
alias gss="git status --short"
alias gs="git status --short"
alias gco="git checkout"
alias goc="git checkout"

alias main="git checkout main && git pull"
alias next="git checkout main && git pull"

alias push="git push"
alias pull="git pull --rebase"
alias gp="git push"
alias gpf="git push --force"

alias gaa="git add --all"
alias ga="git add"
alias gc="git commit"

alias gcamd="git status --short && git commit --amend --no-edit --allow-empty && echo 'commit ammended'"
alias gcapf="git status --short && git commit --amend --no-edit --allow-empty && echo 'commit ammended for force push' && git push --force"
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gpsupu='git push --set-upstream "$USER" "$(git branch --show-current)"'
alias ammend="git status --short && git commit --amend --no-edit --allow-empty"
alias ammendf="git status --short && git commit --amend --no-edit --allow-empty && git push --force"

# Other aliases
alias compose="docker compose"
alias cvsconv=csvconv

if test "$SYSTEM_UNAME" = "Darwin"
then alias apt="brew"
fi
