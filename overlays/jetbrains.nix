{ delib, ... }:
delib.overlayModule {
  name = "overlays.jetbrains";
  overlays = [
    (final: prev: {
      fsnotifier = prev.callPackage ../packages/fsnotifier { };
    })
  ];
}
