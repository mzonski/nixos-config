{ delib, ... }:
delib.module (
  let
    overlay = (
      final: prev: {
        fsnotifier = prev.callPackage ../packages/fsnotifier { };
      }
    );
  in
  {
    name = "overlays.jetbrains";

    nixos.always.nixpkgs.overlays = [
      overlay
    ];

    home.always.nixpkgs.overlays = [
      overlay
    ];
  }
)
