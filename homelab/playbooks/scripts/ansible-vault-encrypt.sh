#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

# Requirements:
# - must accept exactly two arguments: the input file path and the output file path
# - if the input file does not exist, the script should print an error message and exit with a non-zero status
# - if the output file already exists, the script should print a warning message and exit with a non-zero status
# - should use ansible-vault to encrypt the input file and save it to the output file
# - if the encryption is successful, the script should print a success message
# - if the encryption fails, the script should print an error message and exit with a non-zero status
# - should handle any other unexpected errors gracefully, printing an appropriate message and exiting with a non-zero status
# - should use functions to organize the code and improve readability
# - should include comments to explain the purpose of each function and any complex logic
# - should follow best practices for bash scripting, including using set -o errexit
#   and set -o pipefail, and avoiding the use of eval
# - should be idempotent, meaning that running it multiple times with the same input
#   should produce the same output without causing errors or unintended side effects
# - should validate the input arguments to ensure they meet the expected format and constraints
# - should log its actions to a file for auditing purposes
# - must re-encrypt the file if it is already encrypted
# - should read the vault password from the keyring

source "$(dirname "$0")/common.sh"

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
     then log "Reading vault password '$password_name' from keyring using secret-tool."
          secret-tool lookup service "$password_name"
     else err "secret-tool command not found. Please install libsecret-tools."
          return 1
     fi
}

encrypt-files() {
     if test "$#" -eq 0
     then usage
          return 1
     fi

     local vault_password_current
     local vault_password_previous
     if vault_password_current="$(read-password homelab-vault-current)" &&
        vault_password_previous="$(read-password homelab-vault-previous)"
     then log "Successfully read current Ansible Vault passwords."
     else err "Failed to read current Ansible Vault passwords." \
              "Please set 'homelab-vault-current' and 'homelab-vault-previous' in secret-tool."
          return 1
     fi

     for file in "$@"
     do encrypt-file "$file" || return 1
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
     then log "Decrypting file '$input_file'."
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

run encrypt-files "$@"
