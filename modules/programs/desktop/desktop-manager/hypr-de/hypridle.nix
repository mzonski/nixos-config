{
  delib,
  lib,
  pkgs,
  homeconfig,
  ...
}:
let
  inherit (delib) module;
  inherit (lib) optionals;
in
module {
  name = "programs.hyprland";

  home.ifEnabled =
    { myconfig, cfg, ... }:
    let
      inherit (myconfig.rice) wallpaper;
      lockEnabled = cfg.idle.lockEnabled;
      swaylock = "${homeconfig.programs.swaylock.package}/bin/swaylock";
      hyprctl = "${homeconfig.wayland.windowManager.hyprland.package}/bin/hyprctl";
    in
    {
      services.hypridle = {
        enable = true;
        package = pkgs.hypridle;
        settings = {
          general = {
            before_sleep_cmd = if lockEnabled then "${swaylock} -f -i ${wallpaper}" else "";
            after_sleep_cmd = "${hyprctl} dispatch dpms on";
            ignore_dbus_inhibit = false;
            ignore_systemd_inhibit = false;
            lock_cmd = if lockEnabled then "${swaylock}" else "";
          };
          listener =
            [
              {
                timeout = cfg.idle.turnOffDisplayTimeout;
                on-timeout = "${hyprctl} dispatch dpms off";
                on-resume = "${hyprctl} dispatch dpms on";
              }
              {
                timeout = cfg.idle.suspendTimeout;
                on-timeout = "systemctl suspend";
              }
            ]
            ++ optionals lockEnabled [
              {
                timeout = cfg.idle.lockTimeout;
                on-timeout = "loginctl lock-session";
              }
            ];
        };
      };
    };
}
