{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "overlays.hyprland";
  overlays = [
    (delib.inputOverlay inputs system "hyprland" "hyprFlake")
    (delib.inputOverlay inputs system "hyprland-plugins" "hyprPluginsFlake")
  ];
}
