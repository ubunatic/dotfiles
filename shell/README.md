# Shell Micro Libs

Small collection of tools for Linux and MacOS terminals.

The scripts should work in `zsh` and `bash`, but some
features may not be present in all systems and shells.

Licence: GPLv3 (see [LICENSE](../LICENSE)), no warranty!

## Usage

Git clone the repo or copy the [shell](.) dir to a local dir, e.g., `$HOME/git/dotfiles`.

Create a `.userrc` in your `$HOME` and `source` all custom things in there. This helps keeping your OS-provided `.profile`, `.bashrc` and `.zshrc` replacable with newer versions.

Here is an example `.userrc`.
```bash
# Import my dotfiles (based on https://codeberg.org/ubunatic/dotfiles)
export DOTFILES="$HOME/git/dotfiles"
if test -e "$DOTFILES/shell/userrc.sh"
then source $DOTFILES/shell/userrc.sh
fi

# Add private vars here (outside of the system or default dotfiles)
PRIVATE_SERVER="my-server.com"
PRIVATE_ACCOUNT="my-account@my-server.com"

# etc.
```
This is your private file. Do not commit it anywhere!

Before adding it, do a test run:
```bash
source ~/.userrc
```
Repeat this at least once. The first run may show some build/test logs but should without errors. The 2nd run should be silent and run without errors.

Source this `.userrc` in your `.profile` where it is loaded once per login shell. \
Source it `.bashrc` or `.zshrc` where it is loaded for all shell sessions.

## Features
* `gcloud` wrappers to simplify managing GCP resources
* `gsu` "gsutil" with impersonation support
* `git` wrappers to simplify complex tasks
* detect and activate default Python `.venv`
* logging functions (used by other features)
* some color helpers
* ZSH and BASH compatibility

## Development

* Fork and clone the repo.
* Run the tests (requires `bash` AND `zsh` installed).
  ```bash
  DOTFILES_AUTOTEST=1 source $DOTFILES/shell/userrc.sh
  ```
  Read the test output and fix the issues.
* Add a new scripts in the [shell](.) dir and `source` the new script in [userrc.sh](userrc.sh).
* **Please** write tests and add them to `DOTFILES_TESTS` in [test.sh](test.sh).

## Hints
Desktop environment startup scripts do not like if sourced scripts behave badly.
* Do not `echo` (or `log`, `err`, `dbg`) anything during the `source` phase.
* Do not fail during the `source` phase.
* Do not use `DOTFILES_AUTOTEST=1` in your `$HOME/.userrc`.
* Running the tests always yields exit code `0` for now; check output for errors!
