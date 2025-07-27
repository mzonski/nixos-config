{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "unstable";
  overlay =
    final: prev:
    let
      inherit (final) config;
      unstable = import inputs.nixpkgs-unstable {
        inherit system config;
      };
    in
    {
      inherit unstable;
    };
}
