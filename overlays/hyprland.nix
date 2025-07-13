{
  inputs,
  delib,
  system,
  ...
}:
delib.module (
  let
    overlay = (
      final: prev: {
        hyprFlake = inputs.hyprland.packages.${system};
        hyprPluginsFlake = inputs.hyprland-plugins.packages.${system};
      }
    );
  in
  {
    name = "overlays";

    nixos.always.nixpkgs.overlays = [
      overlay
    ];

    home.always.nixpkgs.overlays = [
      overlay
    ];
  }
)
