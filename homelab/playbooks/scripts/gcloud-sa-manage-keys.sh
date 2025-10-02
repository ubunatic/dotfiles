#!/usr/bin/env bash

# This script deletes a Google Cloud service account key file if it exists.
# Arguments:
#   $1 - Service account project (e.g., my-gcp-project)
#   $2 - Service account name (e.g., my-service-account)
#   $3 - Service account action (e.g., create, delete, list)
#   $4 - ID OR FILE OR "all"
#        ID:    Service account key ID (e.g., 1234567890abcdef)
#        "all": delete all keys for the service account (only for delete action)
#        FILE:  Service account key file (optional, default: .vault/<service_account_name>/<service_account_project>-service-account.json)

# AI: First read the Bash programming rules in the project's AGENTS.md.
#     You must not violate any of these rules, esp. the ones for BASH conditionals.

source "$(dirname "$0")/common.sh"

usage() {
     echo "Usage: $0 <sa_project> <sa_name> <sa_keyid_or_file>"
     exit 1
}

list_keys() {
     local sa_email="$1"
     local sa_project="$2"
     local format="${3:-value(name)}"
     local extra_args="${4:---managed-by=user}"
     gcloud iam service-accounts keys list \
          --iam-account "$sa_email" \
          --project "$sa_project" \
          --format="$format" $filter \
          $extra_args
}

get_id_from_keyfile() {
     local keyfile="$1"
     if test -f "$keyfile"
     then jq -r '.private_key_id' "$keyfile"
     else warn "Key file '$keyfile' does not exist."
          return 1
     fi
}

delete_key() {
     local sa_email="$1"
     local sa_project="$2"
     local sa_key="$3"
     local sa_key_or_file

     if gcloud iam service-accounts keys delete "$sa_key" --iam-account "$sa_email" --project "$sa_project" --quiet
     then ok  "Deleted key '$sa_key' for service account '$sa_email' in project '$sa_project'."
     else err "Failed to delete key '$sa_key' for service account '$sa_email' in project '$sa_project'."
          return 1
     fi

     if test -f "$sa_key_file"
     then log "Key file '$sa_key_file' exists, checking if it matches deleted key ID '$sa_key'."
     else log "Key file '$sa_key_file' does not exist. No action taken."
          return 0
     fi

     if sa_key_or_file=$(get_id_from_keyfile "$sa_key_file")
     then if test "$sa_key_or_file" = "$sa_key"
          then rm -f "$sa_key_file"
               ok  "Deleted key file '$sa_key_file' for deleted key ID '$sa_key'."
          else wrn "Key ID in file '$sa_key_or_file' does not match deleted key ID '$sa_key'. Not deleting key file."
          fi
     else err "Could not extract key ID from file '$sa_key_file'. Not deleting key file."
          return 1
     fi
}

manage_service_account_keyfiles() {
     local sa_project="$1"
     local sa_name="$2"
     local sa_action="$3"
     local sa_key_or_file="$4"

     local sa_email="${sa_name}@${sa_project}.iam.gserviceaccount.com"
     local sa_key_dir=".vault/${sa_name}"
     local sa_key_file=".vault/${sa_name}/${sa_project}-service-account.json"

     if test -z "$sa_name" || test -z "$sa_project" || test -z "$sa_action"
     then usage
     fi

     # parse optional ID/key-file argument for create and delete actions
     local sa_key=""
     case "$sa_action" in
     (delete-file|create)
          # arg must be a file path or empty
          if test -z "$sa_key_or_file"
          then log "No ID or key-file provided, using default key file path '$sa_key_file'."
          else log "Key file '$sa_key_or_file' provided."
               sa_key_file="$sa_key_or_file"
               sa_key_dir="$(dirname "$sa_key_file")"
          fi
          ;;
     (delete)
          if test -z "$sa_key_or_file"
          then err "Service account key ID or 'all' or <key-file> must be provided for 'delete' action."
               return 1
          fi

          if test -f "$sa_key_or_file"
          then sa_key_file="$sa_key_or_file"
               if sa_key=$(get_id_from_keyfile "$sa_key_file")
               then log "Extracted key ID '$sa_key' from key file '$sa_key_file'."
               else err "Failed to extract key ID from key file '$sa_key_file'."
                    return 1
               fi
          else sa_key="$sa_key_or_file"
          fi
     esac

     case "$sa_action" in
     (list)
          log "Listing key details for service account '$sa_email' in project '$sa_project':"
          list_keys "$sa_email" "$sa_project" "json"
          ;;
     (create)
          log "Creating a new key for service account '$sa_email' in project '$sa_project'."
          if test -f "$sa_key_file"
          then inf "Key file '$sa_key_file' already exists. Not creating a new key to avoid overwriting existing key file."
               return 0
          fi
          mkdir -p "$sa_key_dir"
          if gcloud iam service-accounts keys create "$sa_key_file" --iam-account "$sa_email" --project "$sa_project"
          then ok  "Created new key and saved to '$sa_key_file'."
          else err "Failed to create new key for service account '$sa_email'."
               return 1
          fi
          ;;
     (delete)
          if test -z "$sa_key"
          then err "Service account key ID must be provided for 'delete' action."
               return 1
          fi
          log "Deleting key '$sa_key' for service account '$sa_email' in project '$sa_project'."
          gcloud iam service-accounts keys delete "$sa_key" --iam-account "$sa_email" --project "$sa_project" --quiet
          ;;
     (delete-all)
          local keys
          if keys=$(list_keys "$sa_email" "$sa_project" "value(name)")
          then log "Found service account keys for '$sa_email' in project '$sa_project'."
          else err "Failed to find service account keys for '$sa_email' in project '$sa_project'."
               return 1
          fi
          log "Deleting all keys for service account '$sa_email' in project '$sa_project'."
          for key in $keys; do
               log "Deleting key $key"
               if gcloud iam service-accounts keys delete "$key" --iam-account "$sa_email" --project "$sa_project" --quiet
               then ok  "Deleted key $key successfully."
               else wrn "Failed to delete key $key (non-fatal error, continuing with next key)."
               fi
          done
          ;;
     (delete-file)
          log "Deleting key file '$sa_key_file'."
          if test -f "$sa_key_file"
          then rm -f "$sa_key_file"
               ok  "Deleted key file '$sa_key_file' successfully."
          else log "Key file '$sa_key_file' does not exist. No action taken."
          fi
          ;;
     (*)
          err "Unknown action '$sa_action'. Valid actions are: create, delete, delete-all, delete-file, list."
          return 1
          ;;
     esac
}

run manage_service_account_keyfiles "$@"
