{
  inputs,
  delib,
  system,
  ...
}:
delib.overlayModule {
  name = "overlays.firefox-addons";
  overlays = [
    (delib.inputOverlay inputs system "firefox-addons" "firefoxAddons")
  ];
}
