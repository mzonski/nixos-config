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
    qdirstat = mkBoolOpt false;
  };

  config = mkIf cfg.qdirstat {
    home.packages = (
      with pkgs;
      [
        qdirstat
      ]
    );
  };
}
