{ inputs, delib, ... }:
delib.overlayModule {
  name = "nix-claude-code";
  overlay = inputs.nix-claude-code.overlays.default;
}
