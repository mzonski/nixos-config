{ lib, delib, ... }:
let
  overlayNamePrefix = "overlay";
in
delib.extension {
  name = "overlay-module";
  description = "Provides overlay management for modules with configurable targets";

  config = final: prev: {
    defaultOverlayTargets = [
      "nixos"
      "home"
    ];
  };

  libExtension = config: final: prev: {
    overlayModule =
      {
        name ? overlayNamePrefix,
        overlays ? [ ],
        targets ? config.defaultOverlayTargets,
        restricted ? [ ],
      }:
      let
        finalTargets = if restricted == [ ] then targets else lib.intersectLists targets restricted;

        applyToNixOS = lib.elem "nixos" finalTargets;
        applyToHome = lib.elem "home" finalTargets;
        applyToDarwin = lib.elem "darwin" finalTargets;
      in
      final.module {
        inherit name;

        nixos.always = lib.mkIf applyToNixOS {
          nixpkgs.overlays = overlays;
        };

        home.always = lib.mkIf applyToHome {
          nixpkgs.overlays = overlays;
        };

        darwin.always = lib.mkIf applyToDarwin {
          nixpkgs.overlays = overlays;
        };
      };
  };
}
