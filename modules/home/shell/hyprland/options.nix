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
in
{
  options.hom.shell.hyprland = {
    enable = mkBoolOpt false;
    file-manager-cmd = mkStrOpt "pcmanfm";
    app-launcher-cmd = mkStrOpt "rofi -show drun";
    terminal = mkStrOpt "kitty";
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

      # MOVE OUT
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
          "waybar &"
          #"swaync &"
          #"wl-paste --watch cliphist store &"
          #"hyprlock"
        ];

        general =
          {
            "$mainMod" = "SUPER";
          }
          // {
            gaps_in = 4;
            gaps_out = 8;
            border_size = 2;
            "col.active_border" = "rgb(cba6f7) rgb(94e2d5) 45deg";
            "col.inactive_border" = "0x00000000";
            border_part_of_window = false;
            no_border_on_floating = false;
            layout = "dwindle";
            resize_on_border = true;
          };

        misc = {
          disable_autoreload = true;
          disable_hyprland_logo = true;
          always_follow_on_dnd = true;
          layers_hog_keyboard_focus = true;
          animate_manual_resizes = false;
          enable_swallow = true;
          focus_on_activate = true;
        };

        dwindle = {
          #no_gaps_when_only = true;
          force_split = 0;
          special_scale_factor = 1.0;
          split_width_multiplier = 1.0;
          use_active_for_splits = true;
          pseudotile = "yes";
          preserve_split = "yes";
        };

        master = {
          new_status = "master";
          special_scale_factor = 1;
          #no_gaps_when_only = false;
        };

        decoration = {
          rounding = 0;
          # active_opacity = 0.90;
          # inactive_opacity = 0.90;
          # fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            size = 1;
            passes = 1;
            brightness = 1;
            contrast = 1.4;
            ignore_opacity = true;
            noise = 0;
            new_optimizations = true;
            xray = true;
          };

          #drop_shadow = true;

          #shadow_ignore_window = true;
          #shadow_offset = "0 2";
          #shadow_range = 20;
          #shadow_render_power = 3;
          #"col.shadow" = "rgba(00000055)";
        };

        animations = {
          enabled = true;

          bezier = [
            "fluent_decel, 0, 0.2, 0.4, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutCubic, 0.33, 1, 0.68, 1"
            "easeinoutsine, 0.37, 0, 0.63, 1"
          ];

          animation = [
            # Windows
            "windowsIn, 1, 3, easeOutCubic, popin 30%" # window open
            "windowsOut, 1, 3, fluent_decel, popin 70%" # window close.
            "windowsMove, 1, 2, easeinoutsine, slide" # everything in between, moving, dragging, resizing.

            # Fade
            "fadeIn, 1, 3, easeOutCubic" # fade in (open) -> layers and windows
            "fadeOut, 1, 2, easeOutCubic" # fade out (close) -> layers and windows
            "fadeSwitch, 0, 1, easeOutCirc" # fade on changing activewindow and its opacity
            "fadeShadow, 1, 10, easeOutCirc" # fade on changing activewindow for shadows
            "fadeDim, 1, 4, fluent_decel" # the easing of the dimming of inactive windows
            "border, 1, 2.7, easeOutCirc" # for animating the border's color switch speed
            "borderangle, 1, 30, fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
            "workspaces, 1, 4, easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
          ];
        };

        # mouse binding
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        # windowrule
        windowrule = [
          "float,imv"
          "center,imv"
          "size 1200 725,imv"
          "float,mpv"
          "center,mpv"
          "tile,Aseprite"
          "size 1200 725,mpv"
          "float,title:^(float_kitty)$"
          "center,title:^(float_kitty)$"
          "size 950 600,title:^(float_kitty)$"
          "float,audacious"
          "workspace 8 silent, audacious"
          # "pin,wofi"
          # "float,wofi"
          # "noborder,wofi"
          "tile, neovide"
          "idleinhibit focus,mpv"
          "float,udiskie"
          "float,title:^(Transmission)$"
          "float,title:^(Volume Control)$"
          "float,title:^(Firefox — Sharing Indicator)$"
          "move 0 0,title:^(Firefox — Sharing Indicator)$"
          "size 700 450,title:^(Volume Control)$"
          "move 40 55%,title:^(Volume Control)$"
        ];

        # windowrulev2
        windowrulev2 = [
          "float, title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override, title:^(.*imv.*)$"
          "opacity 1.0 override 1.0 override, title:^(.*mpv.*)$"
          "opacity 1.0 override 1.0 override, class:(Aseprite)"
          "opacity 1.0 override 1.0 override, class:(Unity)"
          "idleinhibit focus, class:^(mpv)$"
          "idleinhibit fullscreen, class:^(firefox)$"
          "float,class:^(zenity)$"
          "center,class:^(zenity)$"
          "size 850 500,class:^(zenity)$"
          "float,class:^(pavucontrol)$"
          "float,class:^(SoundWireServer)$"
          "float,class:^(.sameboy-wrapped)$"
          "float,class:^(file_progress)$"
          "float,class:^(confirm)$"
          "float,class:^(dialog)$"
          "float,class:^(download)$"
          "float,class:^(notification)$"
          "float,class:^(error)$"
          "float,class:^(confirmreset)$"
          "float,title:^(Open File)$"
          "float,title:^(branchdialog)$"
          "float,title:^(Confirm to replace files)$"
          "float,title:^(File Operation Progress)$"

          "opacity 0.0 override,class:^(xwaylandvideobridge)$"
          "noanim,class:^(xwaylandvideobridge)$"
          "noinitialfocus,class:^(xwaylandvideobridge)$"
          "maxsize 1 1,class:^(xwaylandvideobridge)$"
          "noblur,class:^(xwaylandvideobridge)$"
        ];

      };

      extraConfig = "
xwayland {
  force_zero_scaling = true
}

opengl { 
  nvidia_anti_flicker = false
}

";

    };

    programs.direnv = {
      enable = mkDefault true;
    };
  };
}
