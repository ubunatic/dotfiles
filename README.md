[![test status](https://codeberg.org/ubunatic/dotfiles/badges/workflows/pull-request-test.yml/badge.svg?label=test)](https://codeberg.org/ubunatic/dotfiles/actions?workflow=pull-request-test.yml&actor=0&status=0)

# Dotfiles

Personal [Dotfiles](https://wiki.archlinux.org/title/Dotfiles) collection of shell scripts and terminal apps to `source` in my terminal sessions.

## Usage
Fork this repo and clone it to, e.g., `$HOME/git/dotfiles`, then `source` it your `.profile`.
```bash
export DOTFILES=$HOME/git/dotfiles
source "$DOTFILES/shell/userrc.sh"
```
See the [shell](/shell) library for more details.

Alternatively, use the [install.sh](./install.sh) script:
```sh
# with zsh as default shell 
zsh install.sh --help
```
```bash
# with bash as default shell 
./install.sh --help
```
Other shells may not work as expected.

Note that some tools are real [apps](/apps) written in Go. These are compiled once and setup via [shell/go.sh](/shell/go.sh); if `go` is installed on your system. The first `source` may take a few mintes.

## Contribution Guide
Contributions are welcome. Simply fork this repo and create a [Pull Request](https://codeberg.org/ubunatic/dotfiles/pulls). Make sure you stick to the existing `bash` scripting style.

See the [shell](/shell) library for more details.

## License
Ubunatic Dotfiles - Personal collection of shell scripts and terminal apps.

Copyright (C) 2025, Uwe Jugel, [@ubunatic](https://codeberg.org/ubunatic) \
License: GPLv3 or later, see attached [LICENSE](LICENSE)

<span style='font-size:smaller'>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses.
</span>
