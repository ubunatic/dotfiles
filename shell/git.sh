# Git and Github Commands
# =======================

ghdeploytag() {
    err "ghdeploytag not implemented"
}

rebase() {
    local main=${1:-"main"}
    git checkout "$main" &&
    git pull             &&
    git checkout -       &&
    git rebase "$main"
}

grmb() {
    local main=${1:-"main"}
    local current="$(git branch --show-current)"
    local merge_base="$(git merge-base $main $current)"
    local answer=N
    log "# reset command: git reset $merge_base"
    echo "Reset current branch:$current with merge-base:$main (keep all changes, but loose all commits)? (y/N)"
    if read answer && test "$answer" = "y"
    then git reset $merge_base
    else error "aborted: git reset $merge_base"
    fi
}

ghpr() {
gh pr list --author '@me' --json url,title,statusCheckRollup,number,state,commits --jq '.[]' | python3 -c '
import json, sys
for line in sys.stdin:
    pr = json.loads(line)
    n, t, u, s = pr["number"], pr["title"], pr["url"], pr["state"]
    commits, checks = pr["commits"],  pr["statusCheckRollup"]
    header = f"#{n} PR:{s} {u} {t}"
    print(header)
    conclusions = {}
    for c in checks:
        ok, url, name = c["conclusion"], c["detailsUrl"], c["name"][:70]
        conclusions[ok] = conclusions.get(ok, 0) + 1
        print(f"#{n} CHECK:{ok} {url} {name}")
    print(f"#{n} check summary: {conclusions}")
    for c in commits:
        print(f"#{n} COMMIT", c["oid"], "sha:", c["oid"][:8], c["committedDate"], "comment:", c["messageHeadline"])
    print(header)
'
}

export GIT_PRIVATE_EMAIL=""
export GIT_CORPORATE_EMAIL=""
gitmail_indicator() {
    local mail=""
    mail="$(git config user.email)" 2> /dev/null
    case "$mail" in
        "")                     echo "∅" ;;
        "$GIT_CORPORATE_EMAIL") echo "corp" ;;
        "$GIT_PRIVATE_EMAIL")   echo "priv" ;;
        *gmail.com)             echo "gmail" ;;
        *github.com)            echo "ghub" ;;
        *codeberg.org)          echo "berg" ;;
        *)                      echo "$mail" ;;
    esac
}

gitmail_domain() {
    git config user.email | grep -o '[a-z0-9_-]*\.[a-z0-1]*$'
}

gitmail() {
    echo -n "local:  "; git config user.email
    echo -n "global: "; git config --global user.email
}

gitmail_switch() {
    case "$(git config --global user.email)" in
    "$GIT_CORPORATE_EMAIL") git config --global user.email "$GIT_PRIVATE_EMAIL" ;;
    "$GIT_PRIVATE_EMAIL")   git config --global user.email "$GIT_CORPORATE_EMAIL" ;;
    *) error "failed to change gitmail" ;;
    esac
    gitmail
}

gitfiles_changed() {
    local pattern="$1"
    if test -z "$pattern"
    then pattern='.*'
    fi
    git status --short | grep -o -E "[^ ]+\.$pattern$" | xargs echo
}

git-prebase() {
    local main="$1"
    main="${main:-main}"
    git checkout "$main" && git pull && git checkout - &&
    printf "Prepared rebase from $_BOLD${_RED}%s$_RESET. To rebase run: ${_CYAN}git rebase %s$_RESET\n" "$main" "$main"
}

git-log-short() {
    local from="${1:-"origin/main"}" to="${2:-"origin/prod"}"
    git log "$to..$from" --pretty=format:"- %s" |
        grep -ivE "^- Merge branch '(main|prod|$from)' into" |
        sed 's/ pull request / /g' |
        sort -u
}

git-log-summary() {
    echo "----" > /dev/tty
    git-log-short "$@" > /dev/tty
    echo "----" > /dev/tty
    echo "Please write a one-line summary of the changes above:" > /dev/tty
    read -r summary
    echo "$summary"
}
