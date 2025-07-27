{ delib, ... }:
delib.overlayModule {
  name = "jetbrains";
  overlay = final: prev: {
    fsnotifier = prev.callPackage ../packages/fsnotifier { };
  };
}
