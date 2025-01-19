{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  cfg = config.hom.wayland-wm.hyprland;

  inherit (lib')
    mkBoolOpt
    mkStrOpt
    mkNumOpt
    mkEnumOpt
    ;
  inherit (lib) mkIf;

  hyprlandPackages = {
    stable = {
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    unstable = {
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };
    input = {
      package = pkgs.hyprland.hyprland;
      portalPackage = pkgs.hyprland.xdg-desktop-portal-hyprland;
    };
  };
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

    source = mkEnumOpt [ "stable" "unstable" "input" ] null;
  };

  options.hom.wayland-wm.idle = {
    lockEnabled = mkBoolOpt false;
    lockTimeout = mkNumOpt 660;
    turnOffDisplayTimeout = mkNumOpt 600;
    suspendTimeout = mkNumOpt 1800;
  };

  config = mkIf cfg.enable {

    wayland.windowManager.hyprland.package = hyprlandPackages.${cfg.source}.package;
    xdg.portal.extraPortals = [ hyprlandPackages.${cfg.source}.portalPackage ];

    assertions = [
      {
        assertion = cfg.source != null;
        message = "hom.wayland-wm.hyprland.source must be set when using Hyprland";
      }
    ];

    home.packages = with pkgs; [
      hyprpicker
      brightnessctl # Control brightness of monitor
      #grim
      #slurp
    ];
  };
}
