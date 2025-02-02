{ delib, lib, ... }:
let
  inherit (lib) concatLists;
  inherit (delib) module;
in
module {
  name = "programs.wayland";

  home.ifEnabled =
    { myconfig, ... }:
    let
      # Firefox-specific configurations
      firefox = {
        v1 = [
          # Sharing indicator positioning
          "float,title:^(Firefox — Sharing Indicator)$" # Make sharing indicator float
          "move 0 0,title:^(Firefox — Sharing Indicator)$" # Position at top-left corner
        ];
        v2 = [
          # Prevent screen timeout during fullscreen videos
          "idleinhibit fullscreen, class:^(firefox)$"
        ];
      };

      # Media player (vlc) configurations
      vlc = {
        v1 = [
          "float,vlc" # Make window floating
          "size 1200 725, initialTitle:VLC media player"
          "idleinhibit focus,vlc" # Prevent screen timeout during playback
        ];
        v2 = [
          # Prevent transparency for better viewing
          "opacity 1.0 override 1.0 override, title:^(.*vlc.*)$"
          "idleinhibit focus, class:^(vlc)$"
        ];
      };

      # Image viewer (imv) configurations
      imv = {
        v1 = [
          "float,ristretto" # Make window floating
          "center,ristretto" # Center on screen
          "size 1200 725,ristretto" # Set specific window size
        ];
        v2 = [
          # Prevent transparency for better viewing
          "opacity 1.0 override 1.0 override, title:^(.*ristretto.*)$"
        ];
      };

      # Terminal (kitty) configurations
      floating_kitty = {
        v1 = [
          "float,title:^(float_kitty)$" # Make specific instance float
          "center,title:^(float_kitty)$" # Center floating instance
          "size 950 600,title:^(float_kitty)$" # Set specific size
        ];
      };

      # Audio applications configurations
      audio = {
        v1 = [
          # Audacious music player
          "float,audacious" # Make window floating
          "workspace 8 silent, audacious" # Open in workspace 8
          # Volume control
          "float,title:^(Volume Control)$" # Make volume control float
          "size 700 450,title:^(Volume Control)$" # Set specific size
          "move 40 55%,title:^(Volume Control)$" # Position on screen
        ];
        v2 = [
          "float,class:^(org.pulseaudio.pavucontrol)$" # Make PulseAudio control float
          "float,class:^(SoundWireServer)$" # Make SoundWire float
        ];
      };

      apps = {
        v1 = [
          "float,gparted" # Make disk mounter float
          "float,title:^(qBittorrent)$" # Make torrent client float
        ];
        v2 = [
          "noinitialfocus,class:jetbrains-toolbox,floating:1"
          "noinitialfocus, class:jetbrains-webstorm, title:^$, initialTitle:^$"
        ];
      };

      # Picture-in-Picture configurations
      pip = {
        v2 = [
          "float, title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"
        ];
      };

      # System dialogs and notifications
      dialogs = {
        v2 =
          let
            floatingClasses = [
              "file_progress"
              "confirm"
              "dialog"
              "download"
              "notification"
              "error"
              "confirmreset"
              "branchdialog"
            ];
            floatingTitles = [
              "Open File"
              "Confirm to replace files"
              "File Operation Progress"
              "Extract"
            ];
          in
          concatLists [
            (map (class: "float,class:^(${class})$") floatingClasses)
            (map (title: "float,title:^(${title})$") floatingTitles)
          ];
      };

      # XWayland bridge configurations
      xwayland = {
        v2 = [
          # Make screen sharing bridge invisible and non-interactive
          "opacity 0.0 override,class:^(xwaylandvideobridge)$" # Makes bridge window invisible
          "noanim,class:^(xwaylandvideobridge)$" # Disables animations
          "noinitialfocus,class:^(xwaylandvideobridge)$" # Prevents focus on start
          "maxsize 1 1,class:^(xwaylandvideobridge)$" # Makes window tiny
          "noblur,class:^(xwaylandvideobridge)$" # Disables blur effect
        ];
      };

      # XWayland bridge configurations
      workspaces = {
        v2 = [
          "float, workspace:1"
        ];
      };
    in
    {
      wayland.windowManager.hyprland.settings = {
        windowrule = concatLists [
          firefox.v1
          vlc.v1
          imv.v1
          floating_kitty.v1
          audio.v1
          apps.v1

        ];
        windowrulev2 = concatLists [
          firefox.v2
          vlc.v2
          imv.v2
          audio.v2
          apps.v2
          pip.v2
          dialogs.v2
          xwayland.v2
          workspaces.v2
        ];
      };
    };
}
