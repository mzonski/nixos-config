{ inputs, delib, ... }:
delib.overlayModule {
  enabled = true;
  name = "bun2nix";
  overlay = inputs.bun2nix.overlays.default;
}
