{
  inputs,
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.hom.wayland-wm.hyprland.enable;
  cfg = config.hom.wayland-wm.hyprland;
  wallpaper = config.hom.theme.wallpaper;
  cursor = config.gtk.cursorTheme;
  monitors = cfg.monitors;
in
{
  config = mkIf enabled {
    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      #QT_QPA_PLATFORMTHEME = "gtk2";
      GDK_BACKEND = "wayland";
      # Additional useful variables for Wayland/Qt
      #QT_QPA_PLATFORMTHEME = "qt5ct"; # For Qt theme configuration
      NIXOS_OZONE_WL = "1"; # For Electron apps to use Wayland
      HYPRCURSOR_THEME = cursor.name;
      HYPRCURSOR_SIZE = cursor.size;
    };

    systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

    wayland.windowManager.hyprland = {
      enable = mkDefault true;
      xwayland.enable = mkDefault true;
      systemd = {
        enable = true;
        # Same as default, but stop graphical-session too
        extraCommands = lib.mkBefore [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };
      package = pkgs.unstable.hyprland;

      settings = {
        # autostart
        exec-once = [
          "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent &"
          "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} --mode fill &"
          "hyprctl setcursor '${cursor.name}' ${toString cursor.size} &"
          "systemctl --user import-environment &"
          "hash dbus-update-activation-environment 2>/dev/null &"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
          #"nm-applet &"
          #"swaybg -m fill -i $(find ~/Pictures/wallpapers/ -maxdepth 1 -type f) &"
          #"poweralertd"
        ];

        general.layout = cfg.defaultLayout;

        monitor = [
          # Primary monitor - will be used if it's the only one connected
          "${monitors.primary.output},3840x2160@60.0,0x450,1.6"
          # Secondary monitor - using preferred to handle disconnection gracefully
          "${monitors.secondary.output},preferred,2400x0,1.6"
          # Catch-all rule for any other displays
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
