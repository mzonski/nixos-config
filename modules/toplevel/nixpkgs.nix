{
  delib,
  lib,
  inputs,
  ...
}:
let
  shared.nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "archiver-3.5.1"
    ];
  };

  # TODO: /root/.config/nixpkgs/config.nix
  files."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
  variables."NIXPKGS_ALLOW_UNFREE" = 1;

  mkConfig = extras: lib.recursiveUpdate shared extras;

in
delib.module {
  name = "nixpkgs";

  nixos.always = mkConfig {
    environment.variables = variables;
  };
  home.always = mkConfig {
    xdg.configFile = files;
    home.sessionVariables = variables;
  };
}
