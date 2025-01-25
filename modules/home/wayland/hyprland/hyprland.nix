{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkDefault mkBefore;

  enabled = config.hom.wayland-wm.hyprland.enable;
  cfg = config.hom.wayland-wm.hyprland;
  wallpaper = config.hom.theme.wallpaper;
  cursor = config.gtk.cursorTheme;
  monitors = cfg.monitors;

  hyprSource = config.windows.hyprland.source;

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
  config = mkIf enabled {
    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      NIXOS_OZONE_WL = "1"; # For Electron apps to use Wayland
      HYPRCURSOR_THEME = cursor.name;
      HYPRCURSOR_SIZE = cursor.size;
    };

    systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd = {
        enable = true;
        extraCommands = mkBefore [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      plugins = [
        pkgs.hyprplugins.hyprbars
        # pkgs.hyprplugins.hyprexpo # hyprexpo is restarting hyprland atm
        # pkgs.hyprplugins.xtra-dispatchers
      ];

      settings = {
        exec-once = [
          "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent &"
          "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} --mode fill &"
          "hyprctl setcursor '${cursor.name}' ${toString cursor.size} &"
          "systemctl --user import-environment &"
          "hash dbus-update-activation-environment 2>/dev/null &"
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
        ];

        monitor = [
          "${monitors.primary.output},3840x2160@60.0,0x450,1.6"
          "${monitors.secondary.output},preferred,2400x0,1.6"
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
  };
}
