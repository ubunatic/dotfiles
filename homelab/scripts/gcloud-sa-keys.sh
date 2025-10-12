#!/usr/bin/env bash

# This script manages Google Cloud service account keys.
# Arguments:
#   $1 - Service account action (e.g., create, delete, list)
#   $2 - Service account project (e.g., my-gcp-project)
#   $3 - Service account name (e.g., my-service-account)
#   $4 - ID OR FILE
#        ID:    Service account key ID (e.g., 1234567890abcdef)
#        FILE:  Service account key file (optional, default: .vault/<service_account_name>/<service_account_project>-service-account.json)

# AI: First read the Bash programming rules in the project's AGENTS.md.
#     You must not violate any of these rules, esp. the ones for BASH conditionals.

source "$(dirname "$0")/common.sh"

usage() {
     echo "Usage: $0 action <sa_project> <sa_name> <sa_keyid_or_file>"
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
     local sa_key_id="$3"
     local sa_key_file="$4"

     if test -z "$sa_key_id"
     then err "Service account key ID must be provided for 'delete' action."
          return 1
     fi

     if gcloud iam service-accounts keys delete "$sa_key_id" --iam-account "$sa_email" --project "$sa_project" --quiet
     then ok  "Deleted key '$sa_key_id' for service account '$sa_email' in project '$sa_project'."
     else err "Failed to delete key '$sa_key_id' for service account '$sa_email' in project '$sa_project'."
          return 1
     fi

     delete_key_file "$sa_key_file" "$sa_key_id"
}

delete_key_file() {
     local sa_key_file="$1"
     local sa_key_id="$2"
     local sa_key_id2

     if ! test -f "$sa_key_file"
     then log "Key file '$sa_key_file' does not exist. No action taken."
          return 0
     fi

     if sa_key_id2=$(get_id_from_keyfile "$sa_key_file")
     then if test -z "$sa_key_id"
          then wrn "No key ID provided to match against key ID '$sa_key_id2' from file '$sa_key_file'. Deleting key file anyway."
          elif test "$sa_key_id" = "$sa_key_id2"
          then log "Key ID in file '$sa_key_id2' matches deleted key ID '$sa_key_id'. Deleting key file."
          else err "Key ID in file '$sa_key_id2' does not match deleted key ID '$sa_key_id'. Cannot delete key file."
               return 1
          fi

          if rm -f "$sa_key_file"
          then ok  "Deleted key file '$sa_key_file' for key ID '$sa_key_id2'."
          else err "Failed to delete key file '$sa_key_file' for key ID '$sa_key_id2'."
               return 1
          fi
     else err "Could not extract key ID from file '$sa_key_file'. Cannot delete key file."
          return 1
     fi
}

create_key() {
     local sa_email="$1"
     local sa_project="$2"
     local sa_key_file="$3"
     local sa_key_dir

     if sa_key_dir="$(dirname "$sa_key_file")"
     then log "Key file directory is '$sa_key_dir'."
     else err "Failed to determine directory for key file '$sa_key_file'."
          return 1
     fi

     if mkdir -p "$sa_key_dir"
     then log "Created directory '$sa_key_dir' for key file '$sa_key_file'."
     else err "Failed to create directory '$sa_key_dir' for key file '$sa_key_file'."
          return 1
     fi

     if gcloud iam service-accounts keys create "$sa_key_file" \
          --iam-account "$sa_email" \
          --project "$sa_project"
     then ok  "Created new key and saved to '$sa_key_file'."
     else err "Failed to create new key for service account '$sa_email'."
          return 1
     fi
}

manage_service_account_keyfiles() {
     local sa_action="$1";
     local sa_project="$2"
     local sa_name="$3"
     local sa_key_or_file="$4"

     # .vault/google-service-account is the default directory for service account key files
     # that is also used by the Ansible role google-service-account

     local sa_email="$sa_name@$sa_project.iam.gserviceaccount.com"
     local sa_key_file=".vault/google-service-account/$sa_name-$sa_project-service-account.json"
     local sa_key_id=""  # key ID for delete action

     if test -z "$sa_name" || test -z "$sa_project" || test -z "$sa_action"
     then usage
          err "Action, service account name, and project must be provided."
          return 1
     fi

     # parse optional ID/key-file argument for create and delete actions
     case "$sa_action" in
     (delete-file|create)
          # arg must be a file path or empty
          if test -z "$sa_key_or_file"
          then log "No ID or key-file provided, using default key file path '$sa_key_file'."
          else sa_key_file="$sa_key_or_file"
               log "Key file set to '$sa_key_file'."
          fi
          ;;
     (delete)
          if test -z "$sa_key_or_file"
          then err "Service account key ID or 'all' or <key-file> must be provided for 'delete' action."
               return 1
          fi

          if test -f "$sa_key_or_file"
          then sa_key_file="$sa_key_or_file"
               if sa_key_id=$(get_id_from_keyfile "$sa_key_file")
               then log "Extracted key ID '$sa_key_id' from key file '$sa_key_file'."
               else err "Failed to extract key ID from key file '$sa_key_file'."
                    return 1
               fi
          else sa_key_id="$sa_key_or_file"
          fi
     esac

     case "$sa_action" in
     (list)
          log "Listing key details for service account '$sa_email' in project '$sa_project':"
          list_keys "$sa_email" "$sa_project" "json"
          ;;
     (create)
          log "Creating new key for service account '$sa_email' in project '$sa_project'."
          create_key "$sa_email" "$sa_project" "$sa_key_file"
          ;;
     (delete)
          log "Deleting key '$sa_key_id' for service account '$sa_email' in project '$sa_project'."
          delete_key "$sa_email" "$sa_project" "$sa_key_id" "$sa_key_file"
          ;;
     (delete-all)
          local keys
          if keys="$(list_keys "$sa_email" "$sa_project" "value(name)")"
          then log "Found num=${#keys[@]} service account keys for '$sa_email' in project '$sa_project'."
          else err "Failed to find service account keys for '$sa_email' in project '$sa_project'."
               return 1
          fi
          log "Deleting all keys for service account '$sa_email' in project '$sa_project'."
          for key in $keys; do
               log "Deleting key $key"
               if delete_key "$sa_email" "$sa_project" "$key" "$sa_key_file"
               then ok  "Deleted key $key successfully."
               else wrn "Failed to delete key $key (non-fatal error, continuing with next key)."
               fi
          done
          ;;
     (delete-file)
          log "Deleting key file '$sa_key_file'."
          delete_key_file "$sa_key_file"
          ;;
     (*)
          err "Unknown action '$sa_action'. Valid actions are: create, delete, delete-all, delete-file, list."
          return 1
          ;;
     esac
}

run manage_service_account_keyfiles "$@"
