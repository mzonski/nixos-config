{
  inputs,
  delib,
  system,
  ...
}:
delib.module (
  let
    overlay = (
      final: prev:
      let
        inherit (final) config;
        unstable = import inputs.nixpkgs-unstable {
          inherit system config;
        };
      in
      {
        inherit unstable;
      }
    );
  in
  {
    name = "overlays.unstable";

    nixos.always.nixpkgs.overlays = [
      overlay
    ];

    home.always.nixpkgs.overlays = [
      overlay
    ];
  }
)
