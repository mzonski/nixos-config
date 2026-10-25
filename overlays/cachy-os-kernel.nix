{ inputs, delib, ... }:
delib.overlayModule {
  enabled = true;
  name = "cachy-os-kernel";
  overlay = inputs.nixos-extra.overlays.nix-cachyos-kernel;
}
