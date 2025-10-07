# Bootstrap Setup

## Requirements
- I can develop playbooks, apps, and scripts on MacOS + Linux (Windows can be ignored)
- Main scripts and make target can be run on both systems
- Only minimal "if OS is XYZ" logic is needed
- Use OS-native package managers (brew, apt)
- Use OS-native secret storage (keyring, libsecret)

## What needs to be bootstrapped?
- Ansible
- Git, Make, libsecret, etc.
- Ansible Collections
- Ansible Vault Password Storage (setup password in OS keyring or libsecret)

## Implementation
See [bootstrap.mk](./bootstrap.mk) for the Makefile implementation.

### OS Switching
- Basic target switching is done via the `HOMELAB_DEVELOPER_OS` environment variable,
  which can be set in the `.env` file. It can be either `mac` or `linux`.
- The `.env` file is a manually created file that is NOT checked into git.
  It contains non-sensitive configuration variables, incl. developer machine details.
- The Makefile uses `brew` on MacOS and `apt` on Linux to install
- Make targets are named `bootstrap-ansible-mac` and `bootstrap-ansible-linux`,
  which can be referenced as `bootstrap-ansible-$(HOMELAB_DEVELOPER_OS)`.
