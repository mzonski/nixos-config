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
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
