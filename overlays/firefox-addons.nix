{
  inputs,
  delib,
  ...
}:
delib.overlayModule {
  name = "firefox-addons";
  overlay = final: prev: {
    firefoxAddons = inputs.nixZpkgs.firefoxAddons;
  };
}
