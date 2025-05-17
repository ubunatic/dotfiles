#!/usr/big/env bash
source "core.sh"

# See expose metrics docs https://docs.docker.com/engine/daemon/prometheus/.
expose-metrics() {
    test-shudo || exit 1
    log "Exposing metrics for docker/podman on host: $remote_host"
    content="{ \"metrics-addr\": \"127.0.0.1:$metrics_port\" }"
    shudo bash -c "cat > ~/Downloads/docker-daemon-config.json" <(echo echo "$content")
    if shudo touch -c /etc/docker/daemon.json
    then log "/etc/docker/daemon.json exists, please edit manually"
    else log "cp ~/Downloads/docker-daemon-config.json /etc/docker/daemon.json"
    fi
}

check-container() {
    shudo $docker ps -f "name=$*" --format "{{.Names}}" | grep -qE "^$*$"
}

install-portainer-agent() {
    if check-container portainer_agent
    then log "portainer_agent container already running"
    else
        shudo $docker run -d \
        -p 9001:9001 \
        --name portainer_agent \
        --restart=always \
        -v "$docker_sock:/var/run/docker.sock" \
        -v "$docker_volumes:/var/lib/docker/volumes" \
        -v /:/host \
        "docker.io/portainer/agent:$portainer_version"
    fi
}

install-portainer() {
    if check-container portainer
    then log "portainer container already running"
    else
        shudo $docker volume create --ignore portainer_data &&
        shudo $docker run -d \
        -p 8000:8000 \
        -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v "$docker_sock:/var/run/docker.sock" \
        -v portainer_data:/data \
        "docker.io/portainer/portainer-ce:$portainer_version"
    fi
}

install-prometheus(){
    shudo apt install prometheus prometheus-node-exporter -y &&
    bush 'systemctl restart prometheus prometheus-node-exporter && systemctl status prometheus'
}

install-node-exporter(){
    shudo apt install prometheus-node-exporter -y
}

install-podman() {
    shudo apt install podman -y
    bush 'systemctl start podman && systemctl status podman'
}

install-cockpit() {
    shudo apt install cockpit cockpit-podman -y
    shudo mkdir -p "$(dirname "$cockpit_listen_conf_file")"
    copy "$(echofile "$cockpit_listen_conf")" "$cockpit_listen_conf_file"
    bush 'systemctl daemon-reload && systemctl restart cockpit.socket && systemctl status cockpit.socket'
}

install-screenfetch() {
    shudo apt install screenfetch -y
}

install-tools() {
    shudo apt install git mc neofetch neovim htop jq yq -y
}

query-cockpit()    { execho curl -s -o /dev/null -k "https://$remote_host:$cockpit_port/metrics"; }
query-prometheus() { execho curl -s -o /dev/null    "http://$remote_host:9090/metrics"; }
query-exporter()   { execho curl -s -o /dev/null    "http://$remote_host:9100/metrics"; }

query-all() {
    query-cockpit &&
    query-prometheus &&
    query-exporter
}

systeminfo() {
    ssh "$remote_addr" neofetch
}