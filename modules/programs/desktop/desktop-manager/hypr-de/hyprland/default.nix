{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib) module;
in
module {
  name = "programs.hyprland";

  options.programs.hyprland = {

  };

  nixos.ifEnabled = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      kitty # hyprland default terminal
    ];

    # TODO: only if source is input
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    # environment.variables = {
    #   AQ_DRM_DEVICES = "/dev/dri/card2";
    # };
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (lib) mkBefore;
      inherit (cfg) monitors;
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

        #LIBVA_DRIVER_NAME = "nvidia";
        #ELECTRON_OZONE_PLATFORM_HINT = "auto";
        #GBM_BACKEND = "nvidia-drm";
        #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
        #NVD_BACKEND = "direct";

        #__GL_VRR_ALLOWED = "1";
        #__GL_GSYNC_ALLOWED = "1";
      };

      systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

      services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;

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
          #pkgs.hyprPluginsFlake.hyprbars
          #pkgs.hyprPluginsFlake.hyprexpo
          # pkgs.hyprPluginsFlake.xtra-dispatchers
        ];

        settings = {
          exec-once = [
            "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent &"
            "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} --mode fill &"
            "hyprctl setcursor '${cursor.name}' ${toString cursor.size} &"
            "systemctl --user import-environment &"
            "hash dbus-update-activation-environment 2>/dev/null &"
            "dbus-update-activation-environment --systemd --all &"
          ];

          cursor = {
            no_warps = true;
            no_hardware_cursors = true;
            #use_cpu_buffer = 1;
            default_monitor = monitors.primary.output;
            #no_break_fs_vrr = 1;
            #no_break_fs_vrr = true;
          };

          monitor = [
            "${monitors.primary.output},3840x2160@60.0,0x450,1.6"
            "${monitors.secondary.output},preferred,2400x0,1.6"
          ];

          render = {
            #allow_early_buffer_release = false;
          };

          misc = {
            disable_autoreload = false;
            disable_hyprland_logo = true;
            always_follow_on_dnd = true;
            layers_hog_keyboard_focus = true;
            animate_manual_resizes = false;
            enable_swallow = true;
            focus_on_activate = true;
            #vfr = 1;
            #vrr = 1;
          };

          xwayland.force_zero_scaling = true;
          opengl.nvidia_anti_flicker = true;
        };
      };
    };
}
