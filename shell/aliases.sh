# Common Aliases
# ==============
#
# Also see the *.sh files for component specific aliases.
#

alias compose=docker-compose
alias pull="git pull"
alias gss="git status --short"
alias gs="git status --short"  # typo for gss
alias gco="git checkout"
alias gaa="git add --all"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gpsupu='git push --set-upstream "$USER" "$(git branch --show-current)"'
alias ll="ls -la"

if test "$SYSTEM_UNAME" = "Darwin"
then alias apt="brew"
fi
