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
  monitors = cfg.monitors;
in
{
  options.hom.shell.hyprland = {
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

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swaybg
      #inputs.hypr-contrib.packages.${pkgs.system}.grimblast
      hyprpicker
      grim
      slurp
      wl-clip-persist
      wf-recorder
      libnotify
      rofi
      kitty
    ];
    systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
    wayland.windowManager.hyprland = {
      enable = mkDefault true;
      xwayland.enable = mkDefault true;
      systemd.enable = mkDefault true;

      settings = {

        # autostart
        exec-once = [
          "systemctl --user import-environment &"
          "hash dbus-update-activation-environment 2>/dev/null &"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
          #"nm-applet &"
          "wl-clip-persist --clipboard both"
          #"swaybg -m fill -i $(find ~/Pictures/wallpapers/ -maxdepth 1 -type f) &"
          #"hyprctl setcursor Nordzy-cursors 22 &"
          #"poweralertd &"
          #"waybar &"
          #"swaync &"
          #"wl-paste --watch cliphist store &"
          #"hyprlock"
        ];

        general.layout = cfg.defaultLayout;

        monitor = [
          # Primary monitor - will be used if it's the only one connected
          "${monitors.primary.output},3840x2160@60.0,0x450,1.6"
          # Secondary monitor - using preferred to handle disconnection gracefully
          "${monitors.secondary.output},preferred,2400x0,1.6"
          # Catch-all rule for any other displays - disabled by default
          #",preferred,auto,1"
        ];

        misc = {
          disable_autoreload = false;
          disable_hyprland_logo = true;
          always_follow_on_dnd = true;
          layers_hog_keyboard_focus = true;
          animate_manual_resizes = false;
          enable_swallow = true;
          focus_on_activate = true;
        };

        xwayland.force_zero_scaling = true;
        opengl.nvidia_anti_flicker = false;
      };
    };

    programs.direnv = {
      enable = mkDefault true;
    };
  };
}
