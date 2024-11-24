#!/usr/bin/env bash

# Configuration will be auto-injected here by the Nix build

# Get current state
current_workspace=$(hyprctl activeworkspace -j | jq '.id')
current_monitor=$(hyprctl activeworkspace -j | jq -r '.monitor')
direction="$1"

# Determine monitor range based on current monitor
case "$current_monitor" in
  "$primary_OUTPUT")
    min_workspace=$primary_MIN_WORKSPACE
    max_workspace=$primary_MAX_WORKSPACE
    ;;
  "$secondary_OUTPUT")
    min_workspace=$secondary_MIN_WORKSPACE
    max_workspace=$secondary_MAX_WORKSPACE
    ;;
  *)
    echo "Unknown monitor: $current_monitor"
    exit 1
    ;;
esac

# Navigate workspaces
if [ "$direction" = "next" ]; then
    [ "$current_workspace" -lt "$max_workspace" ] && \
        hyprctl dispatch workspace "$((current_workspace + 1))"
elif [ "$direction" = "prev" ]; then
    [ "$current_workspace" -gt "$min_workspace" ] && \
        hyprctl dispatch workspace "$((current_workspace - 1))"
fi