{ lib, delib, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (delib) extension;
  inherit (lib)
    elem
    mkIf
    intersectLists
    optional
    ;
  namePrefix = "overlay";
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
        name ? namePrefix,
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
        name = concatStringsSep "." [
          namePrefix
          name
        ];

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
