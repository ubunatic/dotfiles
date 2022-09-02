# Shell Micro Libs

Small collection of tools I use for Linux and MacOS.

The scripts should work in `zsh` and `bash`, but some
features may not be present in all systems and shells.

Enjoy & feel free to copy!

## Usage

Git clone the repo or copy the [shell](.) dir to a local dir, e.g., `$HOME/dotfiles`.

Create a `.userrc` in your `$HOME` and `source` any custom things in there.
Here is an example `.userrc`.
```bash
# import public dotfiles
export DOTFILES=$HOME/dotfiles
if test -e "$DOTFILES/shell//userrc.sh"
then source $DOTFILES/shell/userrc.sh
fi

# add private vars here (outside of the system or default dotfiles)
PRIVATE_SERVER="my-server.com"
PRIVATE_ACCOUNT="my-account@my-server.com"
```

Source this `.userrc` in your `.profile`.

## Features
* `starship` prompt auto-setup
* `gcloud` wrappers to simplify managing GCP resources
* `git` wrappers to simplify complex tasks
* detect and activate default Python `.venv`
* logging functions (used by other features)
* ZSH and BASH compatibility

## Development

* Check out the repo. Open a shell.
* Run the tests (requires `bash` AND `zsh` installed).
  ```
  DOTFILES_AUTOTEST=1 source $DOTFILES/shell/userrc.sh
  ```
  Read the test output and fix the issues.
* Add a new scripts in the [shell](.) dir and `source` the script in [userrc.sh](userrc.sh).
* **Please** write tests and add them to `DOTFILES_TESTS` in [test.sh](test.sh).

## Hints
Desktop environment startup scripts do not like if sourced scripts behave badly.
* Do not `echo` (or `log`, `err`, `dbg`) anything during the `source` phase.
* Do not fail during the `source` phase.
* Do not use DOTFILES_AUTOTEST=1 in your `$HOME/.userrc`.
* Running the tests always yields exit code `0` for now; check output for errors!
