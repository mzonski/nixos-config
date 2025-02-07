{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib)
    noDefault
    strOption
    enumOption
    module
    ;
in
module {
  name = "programs.wayland";

  options.programs.wayland.hyprland = {
    source = noDefault (enumOption [ "stable" "unstable" "input" ] null);
    monitors = {
      primary = {
        output = strOption "DP-4";
        workspaces = [
          1
          2
          3
          4
        ];
      };
      secondary = {
        output = strOption "HDMI-A-4";
        workspaces = [
          5
          6
          7
          8
        ];
      };
    };
  };

  nixos.ifEnabled = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      kitty # hyprland default terminal
    ];

    services = {
      xserver.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
      };
    };

    # TODO: only if source is input
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (lib) mkBefore;
      inherit (cfg.hyprland) monitors;
      inherit (myconfig.rice) wallpaper cursor;
    in
    {
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
          enableXdgAutostart = true;
          extraCommands = mkBefore [
            "systemctl --user stop graphical-session.target"
            "systemctl --user start hyprland-session.target"
          ];
        };

        # TODO: If input
        plugins = [
          pkgs.hyprPluginsFlake.hyprbars
          pkgs.hyprPluginsFlake.hyprexpo
          # pkgs.hyprPluginsFlake.xtra-dispatchers
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

          render = {
            allow_early_buffer_release = false;
          };

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
