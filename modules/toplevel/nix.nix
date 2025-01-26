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
        "ca-derivations"
      ];
      warn-dirty = false;
      flake-registry = ""; # Disable global flake registry
    };
  };
in
delib.module {
  name = "nix";

  nixos.always = shared // {
    nix.package = lib.mkForce pkgs.nixVersions.stable;
  };
  home.always = shared // {
    nix.package = lib.mkDefault pkgs.nixVersions.stable;
  };
}
