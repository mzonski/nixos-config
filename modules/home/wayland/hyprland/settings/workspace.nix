{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.hom.wayland-wm.hyprland;
  enabled = cfg.enable;
  primaryOut = cfg.monitors.primary.output;
  secondaryOut = cfg.monitors.secondary.output;
in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.workspace = [
      "1, monitor:${primaryOut}, name:desktop, default:true, persistent:true"
      "2, monitor:${primaryOut}, name:browser, persistent:true"
      "3, monitor:${primaryOut}, name:terminal, persistent:true"
      "4, monitor:${primaryOut}, name:code, persistent:true"
      "5, monitor:${secondaryOut}, default:true, persistent:true"
      "6, monitor:${secondaryOut}, persistent:true"
      "7, monitor:${secondaryOut}, persistent:true"
      "8, monitor:${secondaryOut}, persistent:true"
    ];
  };
}
