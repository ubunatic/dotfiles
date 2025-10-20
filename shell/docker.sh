
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
        x-all|xall|pall|purge-all)
            log "Purging all containers with '$container stop' and '$container rm'"
            for cname in $("$container" ps -aq); do
                cname="$("$container" inspect --format '{{.Name}}' "$cname")"
                log "✋ Stopping container: $cname"
                "$container" stop "$cname"
                log "🗑️ Removing container: $cname"
                "$container" rm "$cname"
            done
            log "✅ Finished purging all containers"
            log "Containers Status:"
            "$container" ps -a
            ;;
        i|interactive)
            log "Running stop/rm interactive mode"
            shift
            local color_actions="\033[32ms\033[0m:stop, \033[31mr\033[0m:rm, \033[31mx\033[0m:stop+rm, \033[33mn\033[0m:next (default)"
            local cnames=()
            cnames=($("$container" ps -a --format '{{.Names}}'))
            for cname in "${cnames[@]}"; do
                local blue_cname="\033[34m$cname\033[0m"
                echo -n "Chose action for container: $blue_cname ($color_actions)? "
                read -r action
                echo  # new line
                case "$action" in
                    [Ss]|[Ss]top)    log "Stopping container: $cname"; "$container" stop "$cname" ;;
                    [Rr]|[Rr]m)      log "Removing container: $cname"; "$container" rm "$cname" ;;
                    [PpXx]|[Pp]urge) log "Purging container: $cname"; "$container" stop "$cname"; "$container" rm "$cname" ;;
                    [Nn]|[Nn]ext|"") log "Skipping container: $cname"; continue ;;
                    *)               log "❌ Invalid action. Skipping." && continue ;;
                esac
                log "✅ Finished interactive stop/rm for container: $cname"
            done
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
