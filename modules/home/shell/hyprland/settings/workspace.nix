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
  enabled = config.hom.shell.hyprland.enable;
  monitor = config.hom.shell.hyprland.monitors;

in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.workspace = [

      "1,monitor:${monitor.primary}"
      "2,monitor:${monitor.primary}"
      "3,monitor:${monitor.primary}"
      "4,monitor:${monitor.primary}"
      # Bind workspaces 4-6 to HDMI-A-4 (secondary monitor)
      "8,monitor:${monitor.secondary}"
      "9,monitor:${monitor.secondary}"
      "10,monitor:${monitor.secondary}"
    ];
  };
}
