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
  enabled = config.programs.file-manager.app == "pcmanfm";
in
{
  options.programs.file-manager = {
    pcmanfm = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs; [
      pcmanfm
      xarchiver
    ];
  };
}
