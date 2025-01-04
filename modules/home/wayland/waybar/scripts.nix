{
  inputs,
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
  enabled = config.hom.wayland-wm.panel.waybar.enable;
in
{
  config = mkIf enabled {
    home.file = {
      "${config.xdg.configHome}/waybar/scripts" = {
        source = ./scripts;
        recursive = true;
        executable = true;
      };
    };
  };
}
