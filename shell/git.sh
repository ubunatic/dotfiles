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
