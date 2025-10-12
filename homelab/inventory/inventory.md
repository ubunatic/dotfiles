# Inventory Management

## Requirements
- When I develop on Linux I want "localhost" to point to my "nas", which is my main dev machine.
- When I develop on Mac I want "localhost" to run scripts and playbooks on my "mac" as 2nd dev machine.
- All other hosts should be reachable by their hostname.

## Security
- Use SSH keys for remote authentication and 'local' connection for localhost.
- Do not store sensitive information in the inventory file (internal hostnames are ok).

## Switching "localhost" target by OS
Use environment variables so the same inventory can adapt to the OS you run Ansible from.
See `nas_connection` and `mac_connection` variables in the inventory file and their counterpart environment variables
`HOME_NAS_CONNECTION` and `HOME_MAC_CONNECTION` in the .env file in this repo.
