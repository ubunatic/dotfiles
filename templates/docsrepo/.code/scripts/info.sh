#!/usr/bin/env bash
# info.sh — show help and repo structure based on current config

set -o errexit

REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MAKEFILE="${REPO}/Makefile"

# Colours
CYAN='\033[36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Load docsrepo config
if source "${REPO}/.docsrepo" 2>/dev/null
then ORIGIN="${DOCSREPO_ORIGIN}"
     FILES="${DOCSREPO_FILES}"
     DIRS="${DOCSREPO_DIRS}"
else ORIGIN="(not set)"
     FILES=""
     DIRS=""
fi

echo -e "${BOLD}Usage:${RESET} make [target]"
echo
echo -e "${BOLD}Targets:${RESET}"
awk -F ':|##' \
    '/^[a-zA-Z0-9_-]+:/{printf "  \033[36m%-18s\033[0m %s\n", $1, $3} \
     /^##[^#]/{printf "\n\033[1m%s\033[0m\n", substr($0,3)}' \
    "${MAKEFILE}"

echo
echo -e "${BOLD}Config (from .docsrepo):${RESET}"
echo -e "  ${CYAN}ORIGIN${RESET}  = ${ORIGIN}"

echo
echo -e "${BOLD}Synced files:${RESET}"
for f in ${FILES}; do
    if test -f "${REPO}/${f}"
    then echo -e "  ${CYAN}✓${RESET}  ${f}"
    else echo -e "  ${DIM}✗  ${f}${RESET}"
    fi
done

echo
echo -e "${BOLD}Synced dirs:${RESET}"
for d in ${DIRS}; do
    if test -d "${REPO}/${d}"
    then echo -e "  ${CYAN}✓${RESET}  ${d}/"
    else echo -e "  ${DIM}✗  ${d}/${RESET}"
    fi
done

echo
echo -e "${BOLD}Repo structure:${RESET}"
for entry in "${REPO}"/*/; do
    name="${entry%/}"
    name="${name##*/}"
    # skip hidden dirs
    [[ "${name}" == .* ]] && continue
    echo -e "  ${CYAN}${name}/${RESET}"
done
shopt -s nullglob
for entry in "${REPO}"/*.md "${REPO}"/*.yaml "${REPO}"/*.yml; do
    echo -e "  ${entry##*/}"
done
shopt -u nullglob
