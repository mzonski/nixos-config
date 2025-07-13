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
        firefoxAddons = inputs.firefox-addons.packages.${system};
      }
    );
  in
  {
    name = "overlays.firefox-addons";

    nixos.always.nixpkgs.overlays = [
      overlay
    ];

    home.always.nixpkgs.overlays = [
      overlay
    ];
  }
)
