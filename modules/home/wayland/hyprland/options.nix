{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  cfg = config.hom.wayland-wm.hyprland;
in
{
  options.hom.wayland-wm.hyprland = {
    enable = mkBoolOpt false;
    defaultLayout = mkStrOpt "dwindle";
    monitors = {
      primary = {
        output = mkStrOpt "DP-3";
        workspaces = [
          1
          2
          3
          4
        ];
      };
      secondary = {
        output = mkStrOpt "HDMI-A-1";
        workspaces = [
          5
          6
          7
          8
        ];
      };
    };
  };

  options.hom.wayland-wm.idle = {
    lockEnabled = mkBoolOpt false;
    lockTimeout = mkNumOpt 660;
    turnOffDisplayTimeout = mkNumOpt 600;
    suspendTimeout = mkNumOpt 1800;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
      grim
      slurp

      #wf-recorder

      brightnessctl # Control brightness of monitor

      lxqt.lxqt-policykit # Polkit
      # Fixes QT issues
      qt6.qtwayland # For Qt6 applications
      qt5.qtwayland # For Qt5 applications
    ];
  };
}
