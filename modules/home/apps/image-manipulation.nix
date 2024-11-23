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
  cfg = config.hom.apps;
in
{
  options.hom.apps = {
    image-manipulation = mkBoolOpt false;
  };

  config = mkIf cfg.image-manipulation {
    home.packages = with pkgs; [
      inkscape-with-extensions
      gimp-with-plugins
    ];
  };
}
