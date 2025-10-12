#!/usr/bin/env bash
# This script creates a Google Cloud service account key file if it does not exist.

# AI Instructions:
# Never use [[ ... ]] or [ ... ], use the `test` command.
# Indentation:
# - Indent with 5 spaces, no tabs.
# - After "if" indent multi-line conditions with 3 spaces
# - Always prefer good alignment over extra indentation levels and line breaks.

source "$(dirname "$0")/common.sh"

usage() {
     echo "Usage: $0 <sa_project> <sa_name> <sa_dir>"
}

manage_keys() { "$here/gcloud-sa-keys.sh" "$@"; }

create_service_account() {
     local sa_project="$1"
     local sa_name="$2"
     local sa_dir="$3"

     local sa_file="$sa_dir/$sa_name-$sa_project-service-account.json"
     local sa_email="$sa_name@$sa_project.iam.gserviceaccount.com"
     local sa_created_date="$(date +'%Y-%m-%d')"

     if test -z "$sa_name" ||
        test -z "$sa_project" ||
        test -z "$sa_dir"
     then usage
          return 1
     else log "Creating/checking service account key file:"
          txt "   name:    $sa_name"
          txt "   project: $sa_project"
          txt "   dir:     $sa_dir"
          txt "   file:    $sa_file"
     fi

     if mkdir -p "$sa_dir"
     then ok  "Created directory $sa_dir"
     else err "Failed to create directory $sa_dir"
          return 1
     fi

     if test -f "$sa_file"
     then inf "Service account file $sa_file already exists. No action taken."
          return 0
     fi

     if ! command -v gcloud >/dev/null 2>&1
     then err "gcloud command not found. Please install the Google Cloud SDK."
          return 1
     fi

     # check if the service account exists
     if gcloud iam service-accounts describe "$sa_email" --project="$sa_project" --quiet >/dev/null 2>&1
     then inf "Service account $sa_email exists."
     else log "Service account $sa_email does not exist. Creating it now."
          if gcloud iam service-accounts create "$sa_name" \
               --display-name="$sa_name ($sa_created_date)" \
               --project="$sa_project"
          then ok  "Created service account $sa_email"
          else err "Failed to create service account $sa_email."
               return 1
          fi
     fi

     manage_keys create "$sa_project" "$sa_name" "$sa_file"
}

run create_service_account "$@"