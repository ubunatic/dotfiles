#!/usr/bin/env bash

scripts="$(dirname "${BASH_SOURCE:-$0}")/.."

source "$scripts/common.sh"

gcloud_auth="$scripts/gcloud-auth.sh"
gcloud_sa_create="$scripts/gcloud-sa-create.sh"
gcloud_sa_keys="$scripts/gcloud-sa-keys.sh"
secret_tool="$scripts/secret-tool.sh"
vault_encrypt="$scripts/vault-tool.sh"

set -o errexit
set -o pipefail

test_logging() {
     inf "This is an info message."
     log "This is a log message."
     err "This is an error message."
     txt "This is a plain text message."
     txt -n "This is a plain text message without newline at the end: "
     echo "This is added by echo."
}

test_gcloud_auth() {
    bash "$gcloud_auth" token > /dev/null
    bash "$gcloud_auth" project > /dev/null
    bash "$gcloud_auth" project-number > /dev/null
    ok "gcloud authentication and project retrieval tests passed."
}

test_gcloud_sa_create() {
    local sa_name="test-gcloud-sa"
    local sa_dir=".vault/test"
    local sa_project

    trap "rmdir '$sa_dir'" EXIT

    if sa_project="$(bash "$gcloud_auth" project)"
    then log "Using project '$sa_project' for service account tests."
    else err "Failed to get current project for service account tests."
         return 1
    fi

    if bash "$gcloud_sa_create" "$sa_project" "$sa_name" "$sa_dir"
    then ok "Service account '$sa_name' creation succeeded."
    else err "Service account '$sa_name' creation failed."
         return 1
    fi

    local sa_expect_file="$sa_dir/$sa_name-$sa_project-service-account.json"
    if test -f "$sa_expect_file"
    then ok "Service account '$sa_name' file exists."
    else err "Service account '$sa_name' file does not exist."
         return 1
    fi

    if bash "$gcloud_sa_keys" delete "$sa_project" "$sa_name" "$sa_expect_file"
    then ok "Service account '$sa_name' key deletion succeeded."
    else err "Service account '$sa_name' key deletion failed."
         return 1
    fi
}

test_vault_encrypt() {
    local test_file=".vault/test/vault-test-file.txt"
    local content="This is a test file for vault encryption."
    trap "rm -f '$test_file'; rmdir .vault/test || true" EXIT
    echo "$content" > "$test_file"

    log "Testing vault encryption on file '$test_file'."
    if bash "$vault_encrypt" encrypt "$test_file" &&
       grep -qE '^\$ANSIBLE_VAULT;' "$test_file" &&
       bash "$vault_encrypt" decrypt "$test_file" &&
       diff <(echo "$content") "$test_file"
    then ok "Vault encryption and decryption succeeded."
    else err "Vault encryption or decryption failed."
         return 1
    fi
}

test_secret_tool() {
    local service="my_test_secret_$(date +%s)"
    local label="test_label_$(date +%s)"
    local secret="deadbeefcafebabe"

    log "Testing secret-tool with service='$service' and label='$label'."
    if echo "$secret" | bash "$secret_tool" store service "$service" --label="$label"
    then ok  "Secret storage succeeded."
    else err "Secret storage failed."
         return 1
    fi

    local retrieved
    retrieved="$(bash "$secret_tool" lookup service "$service")"
    if test "$retrieved" != "$secret"
    then err "Secret retrieval failed. Expected '$secret', got '$retrieved'."
         return 1
    else ok  "Secret retrieval succeeded."
    fi
}

test_scripts_accessible() {
    for script in "$gcloud_auth" "$gcloud_sa_create" "$gcloud_sa_keys" "$secret_tool" "$vault_encrypt"
    do
        if ! test -x "$script"
        then err "Script '$script' is not accessible or not executable."
             return 1
        else log "Script '$script' is accessible and executable."
        fi
    done
}

main() {
    local t
    if test $# -gt 0
    then
        log "Running specified tests: $*"
        for t in "$@"; do case "$t" in
        (logging)        run test_logging ;;
        (scripts)        run test_scripts_accessible ;;
        (gcloud)         run test_gcloud ;;
        (secret*)        run test_secret_tool ;;
        (*auth)          run test_gcloud_auth ;;
        (*sa*create)     run test_gcloud_sa_create ;;
        (*vault)         run test_vault_encrypt ;;
        (*)              err "Unknown test: $t"; exit 1 ;;
        esac; done
    else
        log "Running all tests."
        run test_scripts_accessible
        run test_logging
        run test_secret_tool
        run test_gcloud_auth
        run test_gcloud_sa_create
        run test_vault_encrypt
    fi
    ok  "All tests passed."
}

main "$@"