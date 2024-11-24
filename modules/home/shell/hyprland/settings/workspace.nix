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
  cfg = config.hom.shell.hyprland;
  enabled = cfg.enable;
  primaryOut = cfg.monitors.primary.output;
  secondaryOut = cfg.monitors.secondary.output;

in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.workspace = [
      "1, monitor:${primaryOut},default:true,persistent:true,name:p_1"
      "2, monitor:${primaryOut},persistent:true,name:p_2"
      "3, monitor:${primaryOut},persistent:true,name:p_3"
      "4, monitor:${primaryOut},persistent:true,name:p_4"
      "5, monitor:${secondaryOut},persistent:true,name:s_1"
      "6, monitor:${secondaryOut},persistent:true,name:s_2"
      "7, monitor:${secondaryOut},persistent:true,name:s_3"
      "8, monitor:${secondaryOut},persistent:true,name:s_4"
    ];
  };
}
