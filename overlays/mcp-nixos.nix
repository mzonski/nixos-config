{ inputs, delib, ... }:
delib.overlayModule {
  name = "mcp-nixos";
  overlay = inputs.nixos-extra.overlays.mcp-nixos;
}
