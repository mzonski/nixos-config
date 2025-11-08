{
  delib,
  lib,
  inputs,
  ...
}:
let
  # TODO: /root/.config/nixpkgs/config.nix
  files."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
  variables."NIXPKGS_ALLOW_UNFREE" = 1;

in
delib.module {
  name = "nixpkgs";

  nixos.always = {
    environment.variables = variables;
    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "archiver-3.5.1"
      ];
    };
  };
  home.always = {
    xdg.configFile = files;
    home.sessionVariables = variables;
  };
}
