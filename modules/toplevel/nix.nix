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
        "https://hydra.zonni.pl"
        "https://cache.nixos-cuda.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://ryoppippi.cachix.org"
      ];
      trusted-public-keys = [
        "hydra.zonni.pl-1:icN1z9gO7ekAyzVJ2vHQSqYgNrg+m4pbj/8h/SXwY5s="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
      ];
    };
  };
  mkConfig = extras: lib.recursiveUpdate shared extras;
in
delib.module {
  name = "nix";

  nixos.always = {
    imports = [ inputs.nixZpkgs.nixosModules.programs-sqlite ];
  }
  // mkConfig {
    nix.package = lib.mkForce pkgs.nixVersions.stable;
  };

  home.always = mkConfig {
    nix.package = lib.mkDefault pkgs.nixVersions.stable;
  };
}
