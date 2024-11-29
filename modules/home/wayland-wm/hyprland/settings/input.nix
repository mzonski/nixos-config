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
  enabled = config.hom.wayland-wm.hyprland.enable;
in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland.settings.input = {
      kb_layout = "pl";
      kb_options = "grp:alt_caps_toggle";
      numlock_by_default = true;
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
        natural_scroll = false;
      };
    };
  };
}
