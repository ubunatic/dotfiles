#!/usr/bin/env bash

# This script authenticates to Google Cloud using the local gcloud CLI.
# It used the users default application credentials and can print the access token.

# Auth Flow:
# 1. Check if gcloud is installed.
# 2. Check if user is logged in and authenticate if not.
# 3. Check if a project is set.
# 4. Optionally print the access token.
#
# Arguments:
#   $1 - Action           auth, token
#   $2 - Project ID       my-gcp-project (optional)

# AI Instructions:
# - ALWAYS use 'test ...' for conditionals.
# - NEVER use '[ ... ]' for conditionals.
# - See Agents.md for more information in the root of this repository.

source "$(dirname "${BASH_SOURCE:-$0}")/common.sh"

set -o errexit
set -o pipefail

authenticate() {
     local account=""

     if ! command -v gcloud &>/dev/null
     then err "gcloud CLI not found. Please install it first."
          return 1
     fi

     account="$(gcloud auth list --filter=status:ACTIVE --format="value(account)")"

     if test -z "$account"
     then inf "No active account found. Running 'gcloud auth login'..."
          gcloud auth login --brief --no-launch-browser
     else inf "Active account found: '$account'"
     fi
}

get_current_project() {
     local project=""
     project="$(gcloud config get-value project 2>/dev/null || true)"

     if test -z "$project"
     then err "No project set. Please provide set a project using 'gcloud config set project PROJECT_ID'."
          return 1
     else inf "Current project: '$project'"
          echo "$project"
     fi
}

get_project_number() {
     local project_id="$1"
     local project_number=""

     if test -z "$project_id"
     then log "No project ID provided. Getting current project..."
          if project_id="$(get_current_project)" && test -n "$project_id"
          then log "Using current project ID '$project_id'."
          else err "Failed to get current project."
               return 1
          fi
     fi

     if project_number="$(gcloud projects describe "$project_id" --format="value(projectNumber)" 2>/dev/null)" &&
        test -n "$project_number"
     then log "Got project number '$project_number' for project ID '$project_id'."
          echo "$project_number"
     else err "Failed to get project number for project ID '$project_id'."
          return 1
     fi
}

get_access_token() {
     if ! authenticate
     then err "Must be authenticated to get access token."
          return 1
     fi

     local token=""
     token="$(gcloud auth print-access-token)"

     if test -z "$token"
     then err "Failed to get access token."
          return 1
     else inf "Access token: ${token:0:4}... (truncated)"
          echo "$token"
     fi
}

usage() {
     cat <<EOF
Usage: $(basename "$0") <action> [project_id]
Actions:
  auth        Authenticate to Google Cloud and set the project (if provided)
  token       Get the access token for the current user and project
EOF
}

main() {
     local action="$1"
     case "$action" in
     (auth)
          run authenticate
          ;;
     (token)
          run get_access_token
          ;;
     (project)
          run get_current_project
          ;;
     (project-number)
          run get_project_number "$2"
          ;;
     (*)
          usage
          exit 1
          ;;
     esac
}

main "$@"