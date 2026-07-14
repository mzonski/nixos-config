{ delib, ... }:
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
    };
  };
  home.always = {
    xdg.configFile = files;
    home.sessionVariables = variables;
  };
}
