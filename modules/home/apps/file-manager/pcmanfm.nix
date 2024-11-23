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
  cfg = config.hom.apps.file-manager;
in
{
  options.hom.apps.file-manager = {
    pcmanfm = mkBoolOpt false;
  };

  config = mkIf cfg.pcmanfm {
    home.packages = with pkgs; [
      pcmanfm
      xarchiver
    ];
  };
}
