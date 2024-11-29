{
  config,
  options,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.apps.cli;
in
{

  options.hom.apps.cli = {
    defaults = mkBoolOpt false;
    bash = mkBoolOpt false;
    bat = mkBoolOpt false;
    direnv = mkBoolOpt false;
  };

  config = mkMerge [
    (mkIf cfg.defaults {
      home.packages = with pkgs; [
        bc # Calculator
        bottom # System viewer (btm)
        htop # better top
        ncdu # Calculates space usage of files
        fd # Better find
        jq # JSON pretty printer and manipulator
        timer

        tldr # quick man
        # holywood # i'm cool boi so i need to install it xd

        curl
        wget
        tree
      ];
    })

    (mkIf cfg.bash {
      programs.bash.enable = true;
    })

    (mkIf cfg.bat {
      programs.bat.enable = true;
    })

    (mkIf cfg.direnv {
      programs.direnv = {
        enable = mkDefault true;
        nix-direnv.enable = true;
      };
    })
  ];
}
