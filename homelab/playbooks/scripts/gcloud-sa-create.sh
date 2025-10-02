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
     exit 1
}

manage_keys() { "$here/gcloud-sa-manage-keys.sh" "$@"; }

create_service_account() {
     local sa_project="$1"
     local sa_name="$2"
     local sa_dir="$3"

     local service_account_file="$sa_dir/$sa_name-$sa_project-service-account-test.json"
     local service_account_email="$sa_name@$sa_project.iam.gserviceaccount.com"

     if test -z "$sa_name" ||
        test -z "$sa_project" ||
        test -z "$sa_dir"
     then usage
          return 1
     else log "Creating/checking service account key file:"
          txt "   name:   $sa_name"
          txt "   project: $sa_project"
          txt "   dir:     $sa_dir"
          txt "   file:    $service_account_file"
     fi

     if mkdir -p "$sa_dir"
     then ok  "Created directory $sa_dir"
     else err "Failed to create directory $sa_dir"
          return 1
     fi

     if test -f "$service_account_file"
     then inf "Service account file $service_account_file already exists. No action taken."
          return 0
     fi

     if ! command -v gcloud >/dev/null 2>&1
     then err "gcloud command not found. Please install the Google Cloud SDK."
          return 1
     fi

     # check if the service account exists
     if gcloud iam service-accounts describe "$service_account_email" --project="$sa_project" --quiet >/dev/null 2>&1
     then inf "Service account $service_account_email exists."
     else log "Service account $service_account_email does not exist. Creating it now."
          if gcloud iam service-accounts create "$sa_name" \
               --display-name="$sa_name" \
               --project="$sa_project"
          then ok  "Created service account $service_account_email"
          else err "Failed to create service account $service_account_email."
               return 1
          fi
     fi

     manage_keys "$sa_project" "$sa_name" create "$service_account_file"
}

run create_service_account "$@"
