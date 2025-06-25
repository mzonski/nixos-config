{
  inputs,
  delib,
  system,
  ...
}:
delib.module {
  name = "overlays.unstable";

  nixos.always.nixpkgs.overlays = [
    (
      final: prev:
      let
        inherit (final) config;
      in
      {
        unstable = import inputs.nixpkgs-unstable {
          inherit system config;
        };
      }
    )
  ];
}
