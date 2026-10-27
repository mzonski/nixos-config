{ inputs, delib, ... }:
delib.overlayModule {
  name = "nixZpkgs";
  overlay = inputs.nixZpkgs.overlays.default;
}
