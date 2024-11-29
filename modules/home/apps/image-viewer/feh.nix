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
  cfg = config.hom.apps.image-viewer;
in
{
  options.hom.apps.image-viewer = {
    feh = mkBoolOpt false;
  };

  config = mkIf cfg.feh {
    programs.feh.enable = true;
    programs.feh.package = pkgs.feh;
  };
}
