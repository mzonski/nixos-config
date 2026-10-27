{ inputs, delib, ... }:
delib.overlayModule {
  enabled = true;
  name = "cachy-os-kernel";
  overlay = inputs.nixZpkgs.overlays.nix-cachyos-kernel;
}
