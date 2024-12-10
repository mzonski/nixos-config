{
  config,
  lib,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.wayland-wm.hyprland;
  enabled = cfg.enable;
  primaryOut = cfg.monitors.primary.output;
  secondaryOut = cfg.monitors.secondary.output;

in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.workspace = [
      "1, monitor:${primaryOut},default:true,persistent:true"
      "2, monitor:${primaryOut},persistent:true"
      "3, monitor:${primaryOut},persistent:true"
      "4, monitor:${primaryOut},persistent:true"
      "5, monitor:${secondaryOut},persistent:true"
      "6, monitor:${secondaryOut},persistent:true"
      "7, monitor:${secondaryOut},persistent:true"
      "8, monitor:${secondaryOut},persistent:true"

    ];
  };
}
