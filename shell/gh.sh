
export GH_USER="${GH_USER:-}"

gh-user() {
  if test -n "$GH_USER"
  then echo "$GH_USER"
  else GH_USER="$(gh api user --jq '.login' | cat)"
  fi
}

gh-last-build() {
  local all_fields="databaseId,conclusion,createdAt,displayTitle,event,headBranch,headSha,name,number,status,url,workflowName"
  gh run list -b main -u "$(gh-user)" -L 1 --json "$all_fields" --jq ".[]" "$@"
}

gh-last-build-logs() {
  local run_id

  run_id=$(gh-last-build "$@" | jq .databaseId) &&
  if test -n "$run_id"; then
    log "Fetching logs for run ID: $run_id"
    gh run view "$run_id" --log
  else
    log "No runs found."
  fi
}
