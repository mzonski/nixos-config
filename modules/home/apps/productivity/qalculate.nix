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
    qalculate = mkBoolOpt false;
  };

  config = mkIf cfg.qalculate {
    home.packages = (
      with pkgs;
      [
        qalculate-qt # kalkulator
      ]
    );
  };
}
