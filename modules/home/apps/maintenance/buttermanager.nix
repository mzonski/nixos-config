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
    buttermanager = mkBoolOpt false;
  };

  config = mkIf cfg.buttermanager {
    home.packages = (
      with pkgs;
      [
        buttermanager # manage btrfs
      ]
    );
  };
}
