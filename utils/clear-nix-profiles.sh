#!/usr/bin/env bash

PROFILES_DIR="/nix/var/nix/profiles"

[[ "$1" == "remove" ]] && [[ $EUID -ne 0 ]] && echo "Error: Root required" && exit 1

CURRENT_PROFILE=$(basename "$(readlink "$PROFILES_DIR/system")")
ALL_PROFILES=($(find "$PROFILES_DIR" -maxdepth 1 -name "system-*-link" -exec basename {} \; | sort -V))

if [[ "$1" == "remove" ]]; then
    removed=0
    for profile in "${ALL_PROFILES[@]}"; do
        if [ "$profile" != "$CURRENT_PROFILE" ]; then
            sudo rm "$PROFILES_DIR/$profile" 2>/dev/null && ((removed++))
        fi
    done
    echo "Removed $removed profiles"
else
    echo "Current: $CURRENT_PROFILE"
    echo "Total: ${#ALL_PROFILES[@]} profiles"
fi
