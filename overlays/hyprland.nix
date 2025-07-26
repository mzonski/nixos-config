{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "overlays.hyprland";
  overlay = final: prev: {
    hyprFlake = inputs.hyprland.packages.${system};
    hyprPluginsFlake = inputs.hyprland-plugins.packages.${system};
  };
}
