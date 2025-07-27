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
  name = "add-overlay-module";
  description = "Provides overlay module with configurable targets";

  config = final: prev: {
    defaultOverlayTargets = [
      "nixos"
      "home"
    ];
  };

  libExtension = config: final: _: {
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
        applyToHomeManager = elem "home" finalTargets;
        applyToMacOS = elem "darwin" finalTargets;
      in
      final.module {
        inherit name;

        nixos.always = mkIf applyToNixOS {
          nixpkgs.overlays = finalOverlays;
        };

        home.always = mkIf applyToHomeManager {
          nixpkgs.overlays = finalOverlays;
        };

        darwin.always = mkIf applyToMacOS {
          nixpkgs.overlays = finalOverlays;
        };
      };
  };
}
