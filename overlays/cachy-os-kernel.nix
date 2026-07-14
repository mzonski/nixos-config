{ inputs, delib, ... }:
delib.overlayModule {
  enabled = true;
  name = "cachy-os-kernel";
  overlay = inputs.nix-cachyos-kernel.overlays.default;
}
