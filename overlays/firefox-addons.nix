{
  inputs,
  delib,
  system,
  ...
}:
delib.module {
  name = "overlays.firefox-addons";

  nixos.always.nixpkgs.overlays = [
    (final: prev: {
      firefoxAddons = inputs.firefox-addons.packages.${system};
    })
  ];
}
