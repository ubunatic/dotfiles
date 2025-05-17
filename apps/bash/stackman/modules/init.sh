#!/usr/bin/env bash

# Init phase: cd to script source/module dir. This helps IDE to discover code
# and allows modules to have simpler imports.
cd "$stackman_dir/modules" &&
source "core.sh"    &&
source "args.sh"    &&
source "backup.sh"  &&
source "install.sh" &&
source "test.sh"    &&
cd "$stackman_dir"
