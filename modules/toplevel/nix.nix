{
  delib,
  pkgs,
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
    nix.package = pkgs.nixVersions.stable;
  };
  home.always = shared // {
    nix.package = pkgs.nixVersions.stable;
  };
}
