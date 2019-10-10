#!/bin/bash
# Link any files present in ./userhome to their equivilant paths in ~/
# Writes backups to ./bak with the same structure
# set -x

cd userhome || (echo "userhome doesn't exist. Run from git root" && exit)

backupDir=./bak-$(date +%s)

find . -type f -print0 | while IFS= read -r -d '' gitfile; do

    # Get equivilant from ~/
    target=$(echo "$gitfile" | sed "s+^./+$HOME/+g")
    echo "$target"

    if [[ -f $target ]]; then
        mkdir -p "$backupDir"

        bkpName=$(echo "$target" | sed "s+^$HOME+$backupDir+g")

        mv "$target" "$bkpName"
        echo "Moving $target to $bkpName"
    fi

    mkdir -p "$(dirname $target)"

    ln -s "$gitfile" "$target"
done
