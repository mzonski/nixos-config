{ inputs, delib, ... }:
delib.overlayModule {
  name = "mcp-nixos";
  overlay = inputs.mcp-nixos.overlays.default;
}
