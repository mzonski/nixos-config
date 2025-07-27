{ delib, ... }:
delib.overlayModule {
  name = "overlays.jetbrains";
  overlay = final: prev: {
    fsnotifier = prev.callPackage ../packages/fsnotifier { };
  };
}
