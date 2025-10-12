#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

set -o errexit
set -o pipefail

# Args: FILE  input file to encrypt and overwrite
#
# Encryption:
# - use ansible-vault
# - re-encrypt files when the vault password has changed
# - read the vault password from the keyring or similar secure storage
#
# Errors:
# - handle any other unexpected errors gracefully, printing an appropriate message and exiting with a non-zero status
#
# Code:
# - use functions to organize the code and improve readability
# - add comments to explain the purpose of each function and any complex logic
# - follow best practices for bash scripting as defined in AGENTS.md in this repo
# - make functions idempotent, meaning that running it multiple times with the same input
#   should produce the same output without causing errors or unintended side effects
# - validate the input arguments to ensure they meet the expected format and constraints

usage() { txt "Usage: $0 <input_file> <output_file>"; }

check-encrypted() {
     local file="$1"
     if test -f "$file" && grep -qE '^\$ANSIBLE_VAULT;' "$file"
     then wrn "File '$file' is already encrypted 🔒️."
          return 0
     else log "File '$file' is not encrypted 🔓️."
          return 1
     fi
}

read-password() {
     local password_name="$1"
     if command -v secret-tool >/dev/null 2>&1
     then log "Reading vault password '$password_name' from keyring 🔑 using secret-tool."
          secret-tool lookup service "$password_name"
     else err "secret-tool command not found. Please install libsecret-tools or use a shim."
          return 1
     fi
}

with-passwords() {
     local vault_password_current
     local vault_password_previous
     if vault_password_current="$(read-password homelab-vault-current)" &&
        vault_password_previous="$(read-password homelab-vault-previous)"
     then log "Running command '$1' with Ansible Vault passwords set."
     else err "Failed to read Ansible Vault passwords." \
              "Please set 'homelab-vault-current' and 'homelab-vault-previous' in secret-tool."
          return 1
     fi

     if "$@"
     then log "Vault command '$1' completed successfully."
          return 0
     else err "Vault command '$1' failed."
          return 1
     fi
}

encrypt-files() {
     for file in "$@"
     do encrypt-file "$file" || return 1
     done
}

decrypt-files() {
     for file in "$@"
     do decrypt-file "$file" || return 1
     done
}

encrypt-file() {
     local input_file="$1"

     if test -e "$input_file"
     then log "Input file '$input_file' exists."
     else err "Input file '$input_file' does not exist."
          return 1
     fi

     if test -z "$vault_password_current" ||
        test -z "$vault_password_previous"
     then err "Vault passwords are not set."
          return 1
     fi

     if check-encrypted "$input_file"
     then
          if test "$vault_password_current" = "$vault_password_previous"
          then log "Current and previous vault passwords are the same. No need to re-encrypt"
               return 0
          fi

          log "Decrypting file '$input_file'."
          if ansible-vault decrypt --vault-password-file=<(echo "$vault_password_previous") "$input_file"
          then log "Successfully decrypted file '$input_file'."
          else err "Failed to decrypt file '$input_file'."
               return 1
          fi
     fi

     log "Encrypting file '$input_file'."
     if ansible-vault encrypt --vault-password-file=<(echo "$vault_password_current") "$input_file"
     then ok "Successfully (re-)encrypted file '$input_file'."
          return 0
     else err "Failed to encrypt file '$input_file'."
          return 1
     fi
}

decrypt-file() {
     local input_file="$1"

     if test -e "$input_file"
     then log "Input file '$input_file' exists."
     else err "Input file '$input_file' does not exist."
          return 1
     fi

     if test -z "$vault_password_current" ||
        test -z "$vault_password_previous"
     then err "Vault passwords are not set."
          return 1
     fi

     if check-encrypted "$input_file"
     then
          log "Decrypting file '$input_file'."
          if ansible-vault decrypt --vault-password-file=<(echo "$vault_password_current") "$input_file"
          then ok "Successfully decrypted file '$input_file'."
               return 0
          else err "Failed to decrypt file '$input_file'."
               return 1
          fi
     else
          log "File '$input_file' is not encrypted. No need to decrypt."
          return 0
     fi
}

main() {
     local action="$1"; shift
     case "$action" in
     (encrypt) with-passwords encrypt-files "$@" ;;
     (decrypt) with-passwords decrypt-files "$@" ;;
     (*) err "Unknown action: $action"
         usage
         return 1
         ;;
     esac
}

main "$@"
