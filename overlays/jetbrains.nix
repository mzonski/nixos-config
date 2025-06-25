{ delib, ... }:
delib.module {
  name = "overlays.jetbrains";

  nixos.always.nixpkgs.overlays = [
    (final: prev: {
      fsnotifier = prev.callPackage ../packages/fsnotifier { };
    })
  ];
}
