#!/usr/bin/env bash
# DocsRepo sync script to copy boilerplate files and directories from the origin to the current repo

set -o errexit

err() { echo -n "ERR: "; echo "$@" >&2; }
inf() { echo -n "INF: "; echo "$@" >&2; }

if source .docsrepo
then inf "Loaded configuration from .docsrepo"
else err "Failed to load .docsrepo configuration. Please ensure the file exists and is properly formatted."
     exit 1
fi

ORIGIN="${DOCSREPO_ORIGIN}"
FILES="${DOCSREPO_FILES}"
DIRS="${DOCSREPO_DIRS}"
REPO="$(git rev-parse --show-toplevel || pwd)"

# RSYNC_FILES are files and dirs that can be copied recursively with rsync.
RSYNC_FILES="${FILES} .code .gitignore"
RSYNC="rsync -av --exclude=.code/spec/ --exclude=.code/bin/ --relative"

if test -n "${DIRS}"
then for dir in ${DIRS}
     do RSYNC_FILES="${RSYNC_FILES} ${dir}/README.md"
     done
fi

vars() {
    inf "REPO:        ${REPO}"
    inf "ORIGIN:      ${ORIGIN}"
    inf "FILES:       ${FILES}"
    inf "DIRS:        ${DIRS}"
    inf "RSYNC_FILES: ${RSYNC_FILES}"
    inf "RSYNC:       ${RSYNC}"
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
    check_origin || exit 1
    inf "Copying boilerplate files and directories from ${ORIGIN} to ${REPO}..."
    # cd into ORIGIN so all paths in RSYNC_FILES resolve relative to the source root.
    # rsync flags:
    #   -a   archive mode: recursive + preserves permissions, timestamps, symlinks
    #   -v   verbose: print each transferred file
    #   --relative  preserve the path structure in the destination
    #               e.g. People/README.md lands at REPO/People/README.md, not REPO/README.md
    (cd "${ORIGIN}" && ${RSYNC} ${RSYNC_FILES} "${REPO}/")
}

save_to_origin() {
    check_origin || exit 1
    inf "Saving boilerplate files and directories from current repo to ${ORIGIN}..."
    # rsync flags:
    #   -a   archive mode: recursive + preserves permissions, timestamps, symlinks
    #   -v   verbose: print each transferred file
    #   --relative  preserve the path structure in the destination
    #               e.g. People/README.md lands at ORIGIN/People/README.md, not ORIGIN/README.md
    (cd "${REPO}" && ${RSYNC} ${RSYNC_FILES} "${ORIGIN}/")
}

main() {
    # Load configuration from .docsrepo
    source .docsrepo
    check_origin || exit 1

    cmd="$1"
    case "$cmd" in
        (vars) vars ;;
        (sync) copy_from_origin ;;
        (save) save_to_origin ;;
        ("") err "No command provided. Available commands: vars, sync, save"
             exit 1
             ;;
        *)
             err "Unknown command: '$cmd'. Available commands: vars, sync, save"
             exit 1
             ;;
    esac
}

main "$@"