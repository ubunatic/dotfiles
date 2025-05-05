#!/usr/bin/env bash

export TERM="${TERM:-"xterm-256color"}"

if ls -la &&
   touch -c shell &&
   touch -c shell/userrc.sh
then
   echo "found dotfiles"
else
    echo "dotfiles not found"
    exit 1
fi

test_files="
shell/environment.sh
shell/common.sh
shell/path.sh
shell/config.sh
shell/aliases.sh
shell/editor.sh
shell/system.sh
shell/git.sh
shell/gh.sh
shell/py.sh
shell/go.sh
shell/gomake.sh
shell/swift.sh
shell/gcloud.sh
shell/efiboot.sh
shell/grub.sh
shell/prompt.sh
shell/apps.sh
shell/completions.sh
shell/test.sh
"

for source_file in $(echo $test_files); do
    if source $source_file
    then echo "loaded $source_file"
    else echo "failed to load $source_file"
    fi
done
