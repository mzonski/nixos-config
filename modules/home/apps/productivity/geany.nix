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
  cfg = config.hom.apps.productivity;
in
{
  options.hom.apps.productivity = {
    geany = mkBoolOpt false;
  };

  config = mkIf cfg.geany {
    home.packages = (
      with pkgs;
      [
        geany # text editor
      ]
    );
  };
}
