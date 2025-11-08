#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <HOSTNAME>"
    exit 1
fi

HOSTNAME="$1"
USERNAME="$2"

nixos-rebuild switch \
    --flake ".#${HOSTNAME}" \
    --target-host "${USERNAME}@${HOSTNAME}" \
    --build-host localhost \
    --use-remote-sudo
