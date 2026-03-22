#!/usr/bin/env bash
# DocsRepo sync script to copy boilerplate files and directories from the origin to the current repo

set -o errexit

err() { echo -n "ERR: "; echo "$@" >&2; }
wrn() { echo -n "WRN: "; echo "$@" >&2; }
inf() { echo -n "INF: "; echo "$@" >&2; }

vars() {
    inf "REPO:        ${REPO}"
    inf "ORIGIN:      ${ORIGIN}"
    inf "FILES:       ${FILES[*]}"
    inf "DIRS:        ${DIRS}"
    inf "TREES:       ${TREES}"
    inf "RSYNC_FILES: ${RSYNC_FILES[*]}"
    inf "RSYNC:       ${RSYNC}"
}

source_docsrepo() {
    if ! test -f .docsrepo
    then err "No .docsrepo file found in the current directory. Please create one to configure the sync."
         return 1
    fi

    # shellcheck disable=SC1091
    if source .docsrepo
    then inf "Loaded configuration from .docsrepo"
    else err "Failed to load .docsrepo configuration. Please ensure the file is properly formatted."
        return 1
    fi

    REPO="$(git rev-parse --show-toplevel || pwd)"

    ORIGIN="${DOCSREPO_ORIGIN}"
    FILES=( "${DOCSREPO_FILES[@]}" )
    DIRS="${DOCSREPO_DIRS}"
    TREES="${DOCSREPO_TREES}"

    # RSYNC_FILES are files and dirs that can be copied recursively with rsync.
    # Use a bash array so filenames with spaces are handled correctly.
    RSYNC_FILES=( "${FILES[@]}" .code .gitignore .docsrepo )
    RSYNC="rsync -av --exclude=.code/spec/ --exclude=.code/bin/ --exclude=.code/venv/ --relative"

    # DIRS: only the README.md of each dir is boilerplate
    if test -n "${DIRS}"
    then for dir in ${DIRS}
        do if test -e "${dir}/README.md"
            then RSYNC_FILES+=( "${dir}/README.md" )
            else wrn "Expected README.md in ${dir} but it does not exist. Please update your .docsrepo configuration."
            fi
        done
    fi

    # TREES: the entire directory tree is boilerplate
    if test -n "${TREES}"
    then for tree in ${TREES}
        do RSYNC_FILES+=( "${tree}" )
        done
    fi
}

check_origin() {
    # Check if ORIGIN variable is set and points to a valid directory
    if test -n "${ORIGIN}" && test -d "${ORIGIN}"
    then return 0
    fi

    err "ORIGIN variable is not set or points to a non-existent directory. Please update your .docsrepo configuration."
    return 1
}

copy_from_origin() {
    inf "Copying boilerplate files and directories from ${ORIGIN} to ${REPO}..."
    # cd into ORIGIN so all paths in RSYNC_FILES resolve relative to the source root.
    # rsync flags:
    #   -a   archive mode: recursive + preserves permissions, timestamps, symlinks
    #   -v   verbose: print each transferred file
    #   --relative  preserve the path structure in the destination
    #               e.g. People/README.md lands at REPO/People/README.md, not REPO/README.md
    (cd "${ORIGIN}" && ${RSYNC} "${RSYNC_FILES[@]}" "${REPO}/")
}

list_from_origin() {
    inf "Files that would be synced from ${ORIGIN} to ${REPO} (dry run)..."
    (cd "${ORIGIN}" && ${RSYNC} --dry-run "${RSYNC_FILES[@]}" "${REPO}/")
}

save_to_origin() {
    inf "Saving boilerplate files and directories from current repo to ${ORIGIN}..."
    # rsync flags:
    #   -a   archive mode: recursive + preserves permissions, timestamps, symlinks
    #   -v   verbose: print each transferred file
    #   --relative  preserve the path structure in the destination
    #               e.g. People/README.md lands at ORIGIN/People/README.md, not ORIGIN/README.md
    (cd "${REPO}" && ${RSYNC} "${RSYNC_FILES[@]}" "${ORIGIN}/")
}

list_to_origin() {
    check_origin || exit 1
    inf "Files that would be saved from ${REPO} to ${ORIGIN} (dry run)..."
    (cd "${REPO}" && ${RSYNC} --dry-run "${RSYNC_FILES[@]}" "${ORIGIN}/")
}

main() {
    source_docsrepo || exit 1
    check_origin || exit 1

    cmd="$1"
    case "$cmd" in
        (vars)       vars ;;
        (list-sync)  list_from_origin ;;
        (sync)       copy_from_origin ;;
        (list-save)  list_to_origin ;;
        (save)       save_to_origin ;;
        ("") err "No command provided. Available commands: vars, list-sync, sync, list-save, save"
             exit 1
             ;;
        *)
             err "Unknown command: '$cmd'. Available commands: vars, list-sync, sync, list-save, save"
             exit 1
             ;;
    esac
}

main "$@"