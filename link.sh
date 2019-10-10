#!/bin/bash
# Link any files present in ./userhome to their equivilant paths in ~/
# Writes backups to ./bak with the same structure

backupDir="$PWD/backups/$(date +%s)"
cd userhome || (echo "userhome doesn't exist. Run from git root" && exit)


find "$PWD" -type f -print0 | while IFS= read -r -d '' gitfile; do
    # Get equivilant from ~/
    target=$(echo "$gitfile" | sed "s+^$PWD/+$HOME/+g")

    if [[ -f $target ]]; then
        mkdir -p "$backupDir"

        bkpName=$(echo "$target" | sed "s+^$HOME+$backupDir+g")

        mkdir -p "$(dirname "$bkpName")"

        mv "$target" "$bkpName"
    fi

    mkdir -p "$(dirname "$target")"

    ln -s "$gitfile" "$target"
done
