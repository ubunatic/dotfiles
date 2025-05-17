#!/usr/big/env bash
source "core.sh"

usage() {
    cat <<-EOF
Stackmanager - manage my docker stacks"
Usage: $0 [FLAGS|VARS] COMMAND

Flags:

    --yes -y          auto-confirm execution of remote commands
    --docker          use docker as container manager
    --podman          use podman as container manager
    --local           run commands locally
    --help -h         show this help

Vars:
    key=value         sets the variable "key" to value "value"
    user@host         set remote_host="host" and remote_user="user"

Supported Vars:
$(vars | sed -e 's|^|    |g')

Commands:
    expose-metrics    expose docker metrics
    vars              show variables
    test              run unit tests non-remote functions
    ping              test remote access
    help              show this help
EOF
}

vars() {
    cat <<-EOF
remote_host=$remote_host
remote_user=$remote_user
remote_addr=$remote_addr
metrics_port=$metrics_port
docker=$docker
local=$local
confirm=$confirm
container=$container
portainer_version=$portainer_version
cockpit_port=$cockpit_port
cockpit_https=$cockpit_https
cockpit_listen_conf_file=/etc/systemd/system/cockpit.socket.d/listen.conf
EOF
}

parse-args() {
    test -z "$stackman_parsed" || return 0

    # parse args, vars, and addresses ONCE

    here="$(dirname "$0")"
    stackman_parsed=true

    for flag in $*; do case "$flag" in
        (--help|-h|help) usage; exit 0 ;;
        (-y|--yes)      confirm=yes ;;
        (--docker)      docker=docker
                        docker_sock=/var/run/docker.sock
                        docker_volumes=/var/lib/docker/volumes
                        ;;
        (--podman)      docker=podman ;;
        (--local)       local=local remote_host=localhost remote_user="$USER";;
        (--user)        docker_sock=/var/run/user/1000/podman/podman.sock
                        local=user ;;

        (*@*)   remote_user=$(get-user "$flag")
                remote_host=$(get-host "$flag")
                remote_addr="$remote_user@$remote_host"
                log "setting remote_host=$remote_host"
                log "setting remote_user=$remote_user"
                log "setting remote_addr=$remote_addr"
                ;;

        (*=*)   k="$(get-key "$flag")"
                v="$(get-val "$flag")"
                log "setting $k=$v"
                eval "$k=$v"
                ;;
    esac; done

    # external vars
    remote_host="${remote_host:-pi4}"
    remote_user="${remote_user:-pi}"
    remote_addr="${remote_addr:-$remote_user@$remote_host}"

    metrics_port="${host:-9323}"
    docker="${docker:-podman}"
    docker_sock="${docker_sock:-/run/podman/podman.sock}"
    docker_volumes="${docker_volumes:-/var/lib/containers/storage/volumes}"
    portainer_version="${portainer_version:-lts}"
    confirm="${confirm:-ask}"
    container="${container:-portainer}"
    local="${local:-false}"

    cockpit_port="${cockpit_port:-9070}"
    cockpit_https="${cockpit_https:-}"
    cockpit_listen_conf_file=/etc/systemd/system/cockpit.socket.d/listen.conf
    cockpit_listen_conf="
    [Socket]
    # disable default port 9090 (usually used by prometheus)
    ListenStream=
    # add port 443
    ListenStream=$(test -z "$cockpit_https" || echo 443)
    # add port 9070
    ListenStream=$cockpit_port
    "

    case "$docker" in
        (docker|podman|echo) ;;  # allows vars
        (*)  err "invalid docker executable: docker"; exit 1;;
    esac
}
