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
  thunarPlugins = with pkgs.xfce; [
    thunar-volman
    thunar-archive-plugin
  ];
in
{
  options.hom.apps.file-manager = {
    thunar = mkBoolOpt false;
  };

  config = mkIf cfg.thunar {
    home.packages = with pkgs.xfce; [
      (thunar.override { inherit thunarPlugins; })
    ];
  };
}
