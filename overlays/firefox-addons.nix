{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "firefox-addons";
  overlay = final: prev: {
    firefoxAddons = inputs.firefox-addons.packages.${system};
  };
}
