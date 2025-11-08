#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <HOSTNAME>"
    exit 1
fi

HOSTNAME="$1"
USERNAME="$2"
TEMP_DIR=$(mktemp -d)

retry_with_backoff() {
    local intervals=(15 20 30 60 120)
    local attempt=0
    local max_attempts=${#intervals[@]}
    
    for interval in "${intervals[@]}"; do
        attempt=$((attempt + 1))

        
        if "$@"; then
            echo "Command succeeded!"
            return 0
        else
            echo "Command failed."
            if [[ $attempt -lt $max_attempts ]]; then
                echo "Retrying in ${interval} seconds..."
                sleep "$interval"
            fi
        fi
    done
    
    echo "All $max_attempts attempts failed."
    return 1
}

cleanup() {
    sudo rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TEMP_DIR/etc/ssh"
chmod 777 "$TEMP_DIR/etc/ssh"

sops -d --extract "[\"ssh_private_${HOSTNAME}\"]" ./shared-secrets.yaml > "$TEMP_DIR/etc/ssh/ssh_host_ed25519_key"
sops -d --extract "[\"ssh_public_${HOSTNAME}\"]" ./shared-secrets.yaml > "$TEMP_DIR/etc/ssh/ssh_host_ed25519_key.pub"


sudo chmod 600 "$TEMP_DIR/etc/ssh/ssh_host_ed25519_key"
sudo chmod 640 "$TEMP_DIR/etc/ssh/ssh_host_ed25519_key.pub"
sudo chmod 755 "$TEMP_DIR/etc/ssh"

SSH_PRIVATE_KEY=$(sops -d --extract "[\"ssh_private_${HOSTNAME}\"]" ./shared-secrets.yaml) && \
sudo nix run github:numtide/nixos-anywhere -- \
    --target-host "root@seed" \
    --flake ".#${HOSTNAME}" \
    --extra-files "$TEMP_DIR" \
    --build-on local \
    --phases kexec,disko,install

sudo ssh root@seed 'bootctl --path=/mnt/boot install && reboot'

retry_with_backoff ssh "${USERNAME}@${HOSTNAME}" "(sudo systemctl stop display-manager.service || true) && sudo chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh && sudo reboot"
