{ inputs, delib, ... }:
delib.overlayModule {
  name = "nix-claude-code";
  overlay = inputs.nixos-extra.overlays.nix-claude-code;
}
