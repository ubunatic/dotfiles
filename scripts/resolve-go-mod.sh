#!/bin/bash

set -o errexit  # fail on errors
set -o pipefail # fail if any command in a pipeline fails

common_conflicts() {
    find . -regex '.*/last-updated-at.txt' -print0
    find . -regex '.*/go\.[modsumork]*'    -print0
}

# Check if we're in a rebase
if git rev-parse --is-inside-rebase > /dev/null 2>&1; then
    echo "Rebase detected. Resolving go.mod files..."

    # Find all go.mod files in the repository
    common_conflicts | while IFS= read -r -d $'\0' file; do
        file="${file#./}"  # remove leading ./
        echo -n "Checking: $file"

        # Check if the current go.mod file has conflicts
        if git ls-files --unmerged -- "$file" | grep -q "$file"; then
            echo -n ", conflict detected"

            # Option 1: Use theirs (main's version)
            echo -n ", using 'theirs' version"
            git checkout --theirs -- "$file"

            # Option 2: Run go mod tidy (recommended)
            echo ", checked out 'theirs', running go mod tidy..."
            (cd "$(dirname "$file")" && go mod tidy)

            # Commit the changes
            git add "$file"
            # git commit -m "Resolved go.mod conflict in $file after rebase"
            echo "Resolved and added: $file, please commit manually"
        else
            echo ", no conflict detected"
        fi
    done
else
    echo "Not in a rebase. Skipping go.mod resolution."
fi
