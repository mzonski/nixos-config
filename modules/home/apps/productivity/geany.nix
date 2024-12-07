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
  cfg = config.programs.geany;
in
{
  options.programs.geany = {
    enable = mkBoolOpt false;
    colorScheme = mkEnumOpt [ "catppuccin-mocha" ] null;
  };

  config = mkIf cfg.enable {
    home.packages = (
      with pkgs;
      [
        geany # text editor
      ]
    );

    home.file = mkIf (cfg.colorScheme == "catppuccin-mocha") {
      ".config/geany/colorschemes/catppuccin-mocha.conf".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/geany/970c3408c84e63f052ee961166b6a3df51f865e7/src/catppuccin-mocha.conf";
        sha256 = "sha256-nQb9m6CHiy5ZXP4jmjWwNF4xEPqCc6dNC2rNDg1ut8Q=";
      };
    };
  };
}
