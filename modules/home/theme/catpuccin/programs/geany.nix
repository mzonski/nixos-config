{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.hom.apps.productivity.geany;
in
{
  config = mkIf enabled {
    home.file = {
      ".config/geany/colorschemes/catppuccin-mocha.conf".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/geany/970c3408c84e63f052ee961166b6a3df51f865e7/src/catppuccin-mocha.conf";
        sha256 = "sha256-nQb9m6CHiy5ZXP4jmjWwNF4xEPqCc6dNC2rNDg1ut8Q=";
      };
    };
  };
}
