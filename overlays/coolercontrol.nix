{ delib, ... }:
delib.overlayModule {
  enabled = false;
  name = "coolercontrol";
  overlay = final: prev: {
    coolercontrol = prev.callPackage ../packages/coolercontrol { };
  };
}
