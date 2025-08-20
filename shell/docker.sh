
# AI Assistant Notes
# ------------------
# The funcs in this file must work in Bash and Zsh.
# Always use `test`, never `[` or `[[`.

_dctl_usage() {
    cat <<EOF
Usage: dctl COMMAND [ARGS...]
Manage Docker containers and images using Podman or Docker Compose.

Commands:
    stop-all             Stop all running containers.
    stop-grep <pattern>  Stop containers matching the given pattern.
    rm-all               Remove all containers.
    rm-grep <pattern>    Remove containers matching the given pattern.
    help                 Show this help message.
    container|po         Run ARGS as a container command using the detected container tool.
    compose              Run ARGS as a compose command using the detected compose tool.
    *                    Run a compose command as is.

Options:
    -h, --help  Show this help message (only if -h or --help is the first argument).
    *           Pass through to the detected container or compose command.

EOF
}

# Description: This script contains functions to manage Docker containers and images.
dctl() {(
    set -o pipefail  # Ensure that the script exits if any command in a pipeline fails
    set -o errexit   # Exit immediately if a command exits with a non-zero status

    local container="podman"
    local compose="compose"
    for tool in docker podman; do
        if command -v "$tool" > /dev/null; then container="$tool"; break; fi
    done
    for tool in compose podman-compose docker-compose; do
        if command -v "$tool" > /dev/null; then compose="$tool"; break; fi
    done

    case "$1" in
        -h| --help|help|"") _dctl_usage; return 0 ;;
        stop-all)
            log "Stopping all containers with '$container stop'"
            "$container" ps -q | xargs -r "$container" stop
            ;;
        stop-grep)
            shift
            log "Stopping containers matching pattern '$1' with '$container stop'"
            "$container" ps --format '{{.Names}}'  | grep -E "$1" | xargs -r "$container" stop
            ;;
        rm-all)
            log "Removing all containers with '$container rm'"
            "$container" ps -aq | xargs -r "$container" rm
            ;;
        rm-grep)
            shift
            log "Removing containers matching pattern '$1' with '$container rm'"
            "$container" ps -a --format '{{.Names}}' | grep -E "$1" | xargs -r "$container" rm
            ;;
        container|pod*)
            shift; log "running container command: $*"
            $container "$@" ;;
        compose|stack)
            shift; log "running compose command: $*"
            "$compose" "$@" ;;
        *)  log "running compose command: $*"
            "$compose" "$@"
            ;;
    esac
)}
