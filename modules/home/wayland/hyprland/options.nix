{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  cfg = config.hom.wayland-wm.hyprland;

  inherit (lib') mkBoolOpt mkStrOpt mkNumOpt;
  inherit (lib) mkIf;
in
{
  options.hom.wayland-wm.hyprland = {
    enable = mkBoolOpt false;
    defaultLayout = mkStrOpt "dwindle";
    monitors = {
      primary = {
        output = mkStrOpt "DP-4";
        workspaces = [
          1
          2
          3
          4
        ];
      };
      secondary = {
        output = mkStrOpt "HDMI-A-4";
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
      brightnessctl # Control brightness of monitor
      #grim
      #slurp
    ];
  };
}
