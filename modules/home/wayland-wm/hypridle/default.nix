{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with mylib;
with lib;
let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  wallpaper = config.hom.theme.wallpaper;
  enabled = config.hom.wayland-wm.hyprland.enable;
  cfg = config.hom.wayland-wm.idle;
in
{
  config = mkIf enabled {
    services.hypridle = {
      enable = true;
      package = pkgs.hypridle;
      settings = {
        general = {
          before_sleep_cmd = "${swaylock} -f -i ${wallpaper}";
          after_sleep_cmd = "${hyprctl} dispatch dpms on";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          lock_cmd = "${swaylock}";
        };

        listener =
          [
            {

              timeout = cfg.turnOffDisplayTimeout;
              on-timeout = "${hyprctl} dispatch dpms off";
              on-resume = "${hyprctl} dispatch dpms on";
            }
            {
              timeout = cfg.suspendTimeout;
              on-timeout = "systemctl suspend";
            }
          ]
          # maybe lib.optionals
          ++ optionals cfg.lockEnabled [
            {
              timeout = cfg.lockTimeout;
              on-timeout = "loginctl lock-session";
            }
          ];
      };
    };
  };
}
