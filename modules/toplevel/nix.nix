{
  inputs,
  delib,
  pkgs,
  lib,
  ...
}:
let
  shared.nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      fallback = true;
      download-attempts = 1;
      connect-timeout = 2;
      warn-dirty = false;
      substituters = [
        "https://cache.nixos-cuda.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };
  mkConfig = extras: lib.recursiveUpdate shared extras;
in
delib.module {
  name = "nix";

  nixos.always = {
    imports = [ inputs.flake-programs-sqlite.nixosModules.programs-sqlite ];
  }
  // mkConfig {
    nix.package = lib.mkForce pkgs.nixVersions.stable;
  };

  home.always = mkConfig {
    nix.package = lib.mkDefault pkgs.nixVersions.stable;
  };
}
