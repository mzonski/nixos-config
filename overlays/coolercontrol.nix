{ delib, ... }:
delib.overlayModule {
  enabled = true;
  name = "coolercontrol";
  overlay = final: prev: {
    coolercontrol = prev.callPackage ../packages/coolercontrol { };
  };
}
