# Homelab Roadmap
- [x] Document current situation and plan (this doc)
- [x] Set up Mini PC (Ubuntu LTS)
- [x] Setup GPG and SSH keys for main machines (Mini PC, Laptop, RPis)
- [x] Set up Keepass tooling and cloud sync (Google Drive)
- [ ] Backup GPG and SSH keys to secure location (Keepass file in Google Drive)
- [ ] Backup Keepass master password to secure location where family can access in case of emergency

## Storage and Backup
- [ ] Implement 3-2-1 backup strategy
- [ ] Set up automated backups for all critical data
- [ ] Document backup procedures and recovery plans

## Homelab IaC and Configuration Management
- [x] Create configuration management system (dotfiles repo)
  - [ ] Add inventory file in [homelab/.config](.config)
  - [x] create [homelab/.config](.config) with asymmetric encryption for internal/sensitive data
  - [x] add script to encrypt/decrypt config files: [crypt.sh](.config/crypt.sh)
  - [x] add cloud sync to Google Drive for config files
  - [x] add first config file: [prometheus.yml](.config/prometheus.yml)
  - [ ] add automation to install prometheus and copy config file (Ansible)

Repeat the following for all services:
- [x] Add config file to [homelab/.config](.config)
- [x] Add and run automation to install service and copy config file (Ansible)
- [ ] Test service functionality and backup/restore procedures
- [ ] Document service setup and configuration in [homelab/docs](docs)
- [ ] Uninstall service and reinstall from scratch using only documented procedures and config files
- [ ] Test restore of service data from backup

### Services to manage
- [x] Prometheus (monitoring)
- [ ] Grafana (dashboarding)
- [ ] Node Exporter (system metrics)
- [ ] NFS/Samba (file sharing)
- [ ] Home Assistant (home automation)
- [ ] PiHole (network-wide ad blocking)
- [ ] Immich (photo management)
- [ ] Local LLM (private AI agent for notes, tasks, coding, research, etc.)
- [ ] Markdown-based note-taking system (with AI search, summarization, website generation, etc.)
- [ ] Finance management system (e.g. Firefly III)
- [ ] Password manager (Vaultwarden, with Keepass as backup)
- [ ] Excalidraw (diagramming)
- [ ] Minecraft server management system
- [ ] Jellyfin (media server)
- [ ] Uptime Kuma (service monitoring)
- [ ] Local CI system (that integrates with Codeberg)
- [x] Wireguard (VPN)
- [ ] Tailscale (VPN)
- [ ] Nextcloud (file sync and sharing)
- [ ] Other services as needed
