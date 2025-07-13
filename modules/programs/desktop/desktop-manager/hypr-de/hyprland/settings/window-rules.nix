{ delib, lib, ... }:
let
  inherit (lib) concatLists;
  inherit (delib) module;
in
module {
  name = "programs.hyprland";

  home.ifEnabled =
    { myconfig, ... }:
    let
      firefox = {
        v1 = [
          "float,title:^(Firefox — Sharing Indicator)$"
          "move 0 0,title:^(Firefox — Sharing Indicator)$"
        ];
        v2 = [
          "idleinhibit fullscreen,class:^(firefox)$"
        ];
      };

      vlc = {
        v1 = [
          "float,class:^(vlc)$"
          "size 1200 725,initialTitle:^(VLC media player)$"
          "idleinhibit focus,class:^(vlc)$"
        ];
        v2 = [
          "opacity 1.0 override 1.0 override,title:^(.*vlc.*)$"
          "idleinhibit focus,class:^(vlc)$"
        ];
      };

      ristretto = {
        v1 = [
          "float,class:^(ristretto)$"
          "center,class:^(ristretto)$"
          "size 1200 725,class:^(ristretto)$"
        ];
        v2 = [
          "opacity 1.0 override 1.0 override,title:^(.*ristretto.*)$"
        ];
      };

      floating_kitty = {
        v2 = [
          "float,title:^(float_kitty)$"
          "center,title:^(float_kitty)$"
          "size 950 600,title:^(float_kitty)$"
        ];
      };

      audio = {
        v1 = [
          "float,title:^(Volume Control)$"
          "size 700 450,title:^(Volume Control)$"
          "move 40 55%,title:^(Volume Control)$"
        ];
        v2 = [
          "float,class:^(SoundWireServer)$"
        ];
      };

      apps = {
        v1 = [
          "float,class:^(gparted)$"
          "float,title:^(qBittorrent)$"
        ];
        v2 = [
          "pseudo,class:^(com.obsproject.Studio)$"
        ];
      };

      jetbrains = {
        v2 = [
          "noinitialfocus,class:^(jetbrains-toolbox)$,floating:1"
          # Find in files
          "noinitialfocus,class:^(jetbrains-)(.*),title:^$,initialTitle:^$,floating:1"
          "center,class:^(jetbrains-)(.*),title:^$,initialTitle:^$,floating:1"
          "plugin:hyprbars:nobar,class:^(jetbrains-)(.*),title:^$,initialTitle:^$,floating:1"
          # Other dialogs
          "plugin:hyprbars:nobar,class:^(jetbrains-)(.*),initialTitle:^(.+)$,floating:1"
          "center,class:^(jetbrains-)(.*),initialTitle:^(.+)$,floating:1"
        ];
      };

      gitKraken = {
        v2 = [
          # Splash
          "plugin:hyprbars:nobar,class:^(GitKraken)$,title:^(GitKraken)$,initialTitle:^(GitKraken)$,initialClass:^(GitKraken)$,floating:1"
          "center,class:^(GitKraken)$,title:^(GitKraken)$,initialTitle:^(GitKraken)$,initialClass:^(GitKraken)$,floating:1"
        ];
      };

      pip = {
        v2 = [
          "float,title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override,title:^(Picture-in-Picture)$"
          "pin,title:^(Picture-in-Picture)$"
        ];
      };

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

      xwayland = {
        v2 = [
          "opacity 0.0 override,class:^(xwaylandvideobridge)$"
          "noanim,class:^(xwaylandvideobridge)$"
          "noinitialfocus,class:^(xwaylandvideobridge)$"
          "maxsize 1 1,class:^(xwaylandvideobridge)$"
          "noblur,class:^(xwaylandvideobridge)$"
        ];
      };

      workspaces = {
        v2 = [
          "float,workspace:1"
        ];
      };
    in
    {
      wayland.windowManager.hyprland.settings = {
        windowrule = concatLists [
          firefox.v1
          vlc.v1
          ristretto.v1
          audio.v1
          apps.v1
          firefox.v2
          vlc.v2
          ristretto.v2
          audio.v2
          apps.v2
          pip.v2
          dialogs.v2
          xwayland.v2
          workspaces.v2
          jetbrains.v2
          floating_kitty.v2
          gitKraken.v2
        ];
      };
    };
}
