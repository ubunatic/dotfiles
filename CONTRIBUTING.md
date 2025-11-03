# Contributing to Dotfiles

Thank you for your interest in contributing to this personal dotfiles collection! While this is primarily a personal repository, contributions that improve the codebase are welcome.

## How to Contribute

1. **Fork the repository** and create a new branch for your changes
2. **Follow the coding guidelines** in [AGENTS.md](AGENTS.md)
3. **Test your changes** using `make test`
4. **Submit a Pull Request** with a clear description of your changes

## Coding Standards

### Shell Scripts (Bash)

- **NEVER use** `if [ condition ]` or `if [[ condition ]]`
- **ALWAYS use** `if test condition` for better readability
- Use **5 spaces** for indentation (no tabs)
- Use `$(...)` for command substitution
- Use `set -o errexit` and `set -o pipefail`
- Scripts in `/shell/` must be **sourceable** (no direct execution)

See [AGENTS.md](AGENTS.md) for detailed bash indentation and style rules.

### Go Applications

- Main entry point: `cmd/main.go`
- Use Go modules with base path `ubunatic.com/dotapps/go/`
- Use structured logging with `log/slog`
- CLI apps should use `cobra` for command-line parsing
- Binaries compile to `/bin/`

### Python Applications

- Use type hints
- Follow PEP 8 style guidelines
- Dependencies go in `requirements.txt`
- Prefer simple, single-file scripts

## Testing

Before submitting a PR, run:

```bash
make test
```

For Go-specific tests:

```bash
cd apps/go/<app-name>
go test ./...
```

## Build System

The project uses **GNU Make** as the primary build tool:

- Include files in `/scripts/` provide reusable Makefile targets
- Run `make help` to see available targets

## Pull Request Process

1. Update documentation if you're adding new features
2. Ensure all tests pass
3. Follow existing code patterns
4. Keep commits focused and well-described
5. Reference any related issues

## Questions?

For questions about the codebase:

- Read `README.md` files in relevant directories
- Check existing code patterns
- Review [AGENTS.md](AGENTS.md) for project-specific guidelines

## License

By contributing, you agree that your contributions will be licensed under the same GPLv3 or later license that covers this project. See [LICENSE](LICENSE) for details.
