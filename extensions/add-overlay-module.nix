{ lib, delib, ... }:
let
  inherit (delib) extension;
  inherit (lib)
    elem
    mkIf
    intersectLists
    optional
    ;
in
extension {
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
        name ? "overlay",
        overlay ? null,
        overlays ? [ ],
        targets ? config.defaultOverlayTargets,
        restricted ? [ ],
      }:
      let
        finalOverlays = overlays ++ (optional (overlay != null) overlay);
        finalTargets = if restricted == [ ] then targets else (intersectLists targets restricted);

        applyToNixOS = elem "nixos" finalTargets;
        applyToHome = elem "home" finalTargets;
        applyToDarwin = elem "darwin" finalTargets;
      in
      final.module {
        inherit name;

        nixos.always = mkIf applyToNixOS {
          nixpkgs.overlays = finalOverlays;
        };

        home.always = mkIf applyToHome {
          nixpkgs.overlays = finalOverlays;
        };

        darwin.always = mkIf applyToDarwin {
          nixpkgs.overlays = finalOverlays;
        };
      };
  };
}
