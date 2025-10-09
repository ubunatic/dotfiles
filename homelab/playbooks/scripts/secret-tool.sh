#!/usr/bin/env bash


# Implementation of secret-tool SHELL function for macOS using macOS Keychain
# Usage: same as secret-tool
#
# Example:
# secret-tool lookup service "$service_name"
# secret-tool store --label="$password_label" service "$service_name"
# secret-tool lookup service "$service_name"

# AI Instructions:
# Follow bash scripting best practices as described in AGENTS.md in the root of this repo.
# Do not propose any completions if you do not understand `test` vs. `[ <condition> ]` rule, i.e.
# ALWAYS use `test` for conditional checks and never use `[ <condition> ]`!!!!!

if ! command -v hascommon > /dev/null
then source "$(dirname "${BASH_SOURCE:-$0}")/common.sh"
fi

# secret-tool-mac implements subset of secret-tool functionality using macOS Keychain.
#
# Arguments:
#   lookup|store           secret-tool action, positional argument 0
#   --label="label ..."    secret-tool label arg, used as -l argument to security command, only for store action
#   "service"              secret-tool secret key, must be "service", other keys are not supported
#   service_name           secret-tool secret value, the value of the "service" key
#
# Other arguments are not supported and will result in an error.
# Examples:
#   secret-tool-mac lookup service "$service_name"
#   secret-tool-mac store --label="$password_label" service "$service_name"
#   secret-tool-mac lookup service "$service_name"
#
# Returns:
#   On lookup: prints the found password to stdout, empty string if not found
#   On store: 0 on success, 1 on failure
#
secret-tool-mac() {(
     set -o errexit

     local account="$USER"

     # action is first positional arg and is required
     local action="$1"; shift

     # parse named and positional args to fill service, value, and label args
     local service label

     while test $# -gt 0; do case "$1" in
     (--label=*)  # label arg can be at any position
          label="${1#*=}"
          ;;
     (service)  # key: "service", value: next positional arg
          service="$2"; shift
          ;;
     (*)  # unsupported args
          err "unsupported argument: $1 (action=$action, service=$service, label=$label)"
          return 1
          ;;
     esac; shift; done

     log "Running action=$action for account=$account, service=$service, label=$label"

     local password
     case "$action" in
     (lookup)
          password="$(security find-generic-password -a "$account" -s "$service" -w)"
          log "found password $service in Keychain len=${#password}"
          echo "$password"
          ;;
     (store)
          txt -n "Enter password for service '$service' (account=$account): "
          if read -rs password
          then ok "read password for service '$service', storing in Keychain"
               if security add-generic-password -a "$account" -s "$service" -l "$label" -U -w "$password"
               then ok  "stored password for service '$service' in Keychain"
               else err "failed to store password for service '$service' in Keychain"
                    return 1
               fi
               local verified_password
               verified_password=$(security find-generic-password -a "$account" -s "$service" -w)
               if test "$verified_password" = "$password"
               then ok  "verified password for service '$service' in Keychain"
               else err "password verification failed for service '$service' in Keychain"
                    return 1
               fi
          else err "aborted reading password for service '$service', not storing in Keychain"
               return 1
          fi
          ;;
     (*)
          err "unsupported arguments: $*"
          return 1
          ;;
     esac
)}

secret-tool-lookup-or-store() {
     local service="$1"; shift
     local label="$*"

     # used for store action only, default label if not provided
     if test -z "$label"
     then label="Generic Secret"
     fi

     local password
	if password="$(secret-tool lookup service "$service")"
     then log "found password '$service' in secret-tool"
          echo "$password"
          return 0
     fi

     txt -n "🔑 Enter password '$label: $service' to store in secret-tool:"
     if secret-tool store --label="$label: $service" service "$service"
     then ok "Password '$label: $service' is stored in secret-tool"
     	if password="$(secret-tool lookup service "$service")"
          then log "found password '$service' in secret-tool"
               echo "$password"
               return 0
          else err "Failed to retrieve password '$label: $service' from secret-tool after storing it"
               return 1
          fi
     else err "Failed to store password '$label: $service' in secret-tool"
          return 1
     fi
}

if ismac && ! command -v secret-tool &> /dev/null
then secret-tool() { secret-tool-mac "$@"; }
fi
