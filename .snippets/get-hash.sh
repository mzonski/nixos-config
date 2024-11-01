#!/usr/bin/env bash

# get-hash.sh - Generate Nix-compatible SHA256 hashes for URLs

# Function to print usage
print_usage() {
    echo "Usage: $0 <url>"
    echo "Generates a Nix-compatible SHA256 hash for the content at the given URL"
    echo ""
    echo "Example:"
    echo "  $0 https://raw.githubusercontent.com/user/repo/file.txt"
}

# Check if URL is provided
if [ $# -eq 0 ]; then
    print_usage
    exit 1
fi

URL="$1"

# Check if required commands exist
for cmd in curl sha256sum cut nix-hash; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' not found"
        exit 1
    fi
done

# Fetch URL and generate hash
echo "Fetching: $URL"
HASH=$(nix-hash --to-base64 --type sha256 $(curl -L "$URL" | sha256sum | cut -d ' ' -f 1))

if [ $? -eq 0 ]; then
    echo "sha256-$HASH"
else
    echo "Error: Failed to generate hash"
    exit 1
fi