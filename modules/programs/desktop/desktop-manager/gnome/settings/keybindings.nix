{
  delib,
  pkgs,
  ...
}:
let
  inherit (delib) module;
in
module {
  name = "programs.gnome";

  home.ifEnabled = {
    home.packages = with pkgs; [
      dconf-editor
    ];

    dconf = {
      settings = {
        "org/gnome/desktop/wm/keybindings" = {
          minimize = [ "<Super>comma" ];
          maximize = [ ];
          unmaximize = [ ];
          switch-to-workspace-left = [ ];
          switch-to-workspace-right = [ ];
          move-to-monitor-up = [ ];
          move-to-monitor-down = [ ];
          move-to-monitor-left = [ ];
          move-to-monitor-right = [ ];
          move-to-workspace-down = [ ];
          move-to-workspace-up = [ ];
          switch-to-workspace-down = [
            "<Primary><Super>Down"
            "<Primary><Super>j"
          ];
          switch-to-workspace-up = [
            "<Primary><Super>Up"
            "<Primary><Super>k"
          ];
          toggle-maximized = [ "<Super>f" ];
          close = [
            "<Super>q"
            "<Alt>F4"
          ];
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          move-to-workspace-1 = [ "<Super><Shift>1" ];
          move-to-workspace-2 = [ "<Super><Shift>2" ];
          move-to-workspace-3 = [ "<Super><Shift>3" ];
          move-to-workspace-4 = [ "<Super><Shift>4" ];
        };
        "org/gnome/shell/keybindings" = {
          open-application-menu = [ ];
          toggle-message-tray = [ "<Super>v" ];
          toggle-overview = [ ];
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
          switch-to-application-5 = [ ];
          switch-to-application-6 = [ ];
          switch-to-application-7 = [ ];
          switch-to-application-8 = [ ];
          switch-to-application-9 = [ ];
        };
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ ];
          toggle-tiled-right = [ ];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/open_terminal/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/resume_displays/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/standby_displays/"
          ];
          screensaver = "@as ['<Super>Escape']";
          rotate-video-lock-static = [ ];
          home = [ "<Super>e" ];
          email = [ ];
          www = [ ];
          terminal = [ ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/open_terminal" = {
          binding = "<Super>z";
          command = "kitty"; # TODO: use configured "default"
          name = "Open Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/resume_displays" = {
          command = "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 0";
          binding = "<Super>F1";
          name = "Resume All Displays";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/standby_displays" = {
          command = "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1";
          binding = "<Super><Alt>F1";
          name = "Put All Displays in Standby";
        };
      };
    };
  };
}
