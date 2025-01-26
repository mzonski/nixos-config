{
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
      flake-registry = ""; # Disable global flake registry
    };
  };
  mkConfig = extras: lib.recursiveUpdate shared extras;
in
delib.module {
  name = "nix";

  nixos.always = mkConfig {
    nix.package = lib.mkForce pkgs.nixVersions.stable;
  };

  home.always = mkConfig {
    nix.package = lib.mkDefault pkgs.nixVersions.stable;
  };
}
