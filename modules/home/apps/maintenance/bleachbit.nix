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
  cfg = config.hom.apps.maintenance;
in
{
  options.hom.apps.maintenance = {
    bleachbit = mkBoolOpt false;
  };

  config = mkIf cfg.bleachbit {
    home.packages = (
      with pkgs;
      [
        bleachbit # Program to clean your computer
      ]
    );
  };
}
