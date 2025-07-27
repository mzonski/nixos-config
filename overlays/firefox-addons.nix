{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "overlay.firefox-addons";
  overlay = final: prev: {
    firefoxAddons = inputs.firefox-addons.packages.${system};
  };
}
