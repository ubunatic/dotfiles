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
    local mail="$(git config user.email)"
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
