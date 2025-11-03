# Security Policy

## Supported Versions

This is a personal dotfiles repository. Security updates are applied to the latest version only.

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this dotfiles repository, please report it privately:

1. **Do NOT open a public issue** for security vulnerabilities
2. Contact the repository owner directly via:
   - Codeberg: [@ubunatic](https://codeberg.org/ubunatic)
   - Email: (check profile for contact information)

## Security Considerations

### Shell Scripts

- All shell scripts should be reviewed before sourcing
- Avoid running untrusted code from this repository
- Shell libraries use `set -o errexit` and `set -o pipefail` for error handling
- Scripts in `/shell/` are designed to be sourced safely

### Go Applications

- Go applications are compiled from source
- Dependencies are managed via `go.mod`

### Configuration Files

- Configuration files may contain system-specific settings
- Review configs before applying to your system
- Some configs interact with system keybindings and input devices

### Installation Scripts

- The `install.sh` script modifies shell configuration files
- Always review installation scripts before running
- Create backups of existing configurations before installation

## Best Practices

When using this dotfiles repository:

1. **Fork and review** all code before applying to your system
2. **Test in a VM** or container before applying to your main system
3. **Keep dependencies updated** (run `make test` regularly)
4. **Audit changes** when pulling updates from upstream

## Scope

This security policy applies to:

- Shell scripts in `/shell/`
- Applications in `/apps/`
- Configuration files in `/config/`
- Build and installation scripts

## Disclaimer

This is a personal dotfiles repository provided "AS IS" without warranty. Use at your own risk. See [LICENSE](LICENSE) for full legal details.
