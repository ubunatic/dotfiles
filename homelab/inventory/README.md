# Inventory Management

This is the Ansible inventory for my homelab setup.
Not much here, just a few notes on how I manage it.

## Requirements
- When I develop on Linux I want "localhost" to point to my "nas", which is my main dev machine.
- When I develop on Mac I want "localhost" to run scripts and playbooks on my "mac" as 2nd dev machine.
- All other hosts should be reachable by their hostname.

## Security
- Use SSH keys for remote authentication and 'local' connection for localhost.
- Do not store sensitive information in the inventory files (internal hostnames are ok).

## Switching "localhost" target by OS
Use environment variables so the same inventory can adapt to the OS you run Ansible from.
See `nas_connection` and `mac_connection` variables in the inventory files and their counterpart environment variables
`HOME_NAS_CONNECTION` and `HOME_MAC_CONNECTION` in the [.env](../.env.example) file in this repo.
