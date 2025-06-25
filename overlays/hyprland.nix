{
  inputs,
  delib,
  system,
  ...
}:
delib.module {
  name = "overlays";

  nixos.always.nixpkgs.overlays = [
    (final: prev: {
      hyprland = inputs.hyprland.packages.${system};
      hyprPluginsFlake = inputs.hyprland-plugins.packages.${system};
    })
  ];
}
