#!/usr/bin/env bash
# process *.log and *.log.gz files and provide various utilities
# to search, list, and analyze logs

#shellcheck disable=SC2164

log() { echo "INF: $*" >/dev/stderr; }
err() { echo "ERR: $*" >/dev/stderr; }

all_logs() {
    for f in "$@"; do
        case "$f" in
            *.log)    cat "$f";;
            *.log.gz) cat "$f" | gunzip 2>/dev/null;;
            *)        cat "$f";;
        esac || err "failed to read file: $f"
    done
}

log_proc() {
    if test $# -eq 0
    then cat
    else grep --color -E "$@"
    fi
}

find_users() {
    grep "logged in with entity id" | grep -oE ': [^\[]+' | sort -u | sed 's/^: //'
}

usage() {
    cat <<EOF
Usage: mclogs.sh [command] [files...] [args...]
Commands:
  -h, --help, help   Show this help message
  [l]ist             List all logs
  [g]rep <exp>       Search logs for a specific expression (alias: [s]earch, [f]ind)
  [u]sers            List unique users from the logs

Files:
  *.log, *.log.gz    Specify log files to process (default: all .log and .log.gz files in the current directory)

Extra:
  -h, --help         Show this help message

EOF
}

main() {
    local cmd="usage"
    case "$1" in
        -h|--help|h*) usage; exit 0;;
        l*)       cmd="list";;
        s*|g*|f*) cmd="grep";;
        u*)       cmd="users";;
        *)        err "unknown command: $1"; usage; exit 1;;
    esac
    shift

    local files=()
    local extra=()

    for arg in "$@"; do
        case "$arg" in
            -h|--help) usage; exit 0;;
            *.log|*.log.gz) files+=("$arg");;
            *) extra+=("$arg");;
        esac
    done

    if test ${#files[@]} -eq 0
    then files=(./*.log ./*.log.gz)
    fi

    case "$cmd" in
        list)  log "listing all logs";
               all_logs "${files[@]}";;
        grep)  log "searching logs with grep args: ${extra[*]}"
               all_logs "${files[@]}" | log_proc "${extra[@]}";;
        users) log "listing users from logs"
               all_logs "${files[@]}" | log_proc "${extra[@]}" | find_users;;
        usage) usage;;
    esac
}

main "$@"
