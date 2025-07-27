{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "overlay.hyprland";
  overlay = final: prev: {
    hyprFlake = inputs.hyprland.packages.${system};
    hyprPluginsFlake = inputs.hyprland-plugins.packages.${system};
  };
}
