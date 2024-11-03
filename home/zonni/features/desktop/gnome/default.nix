{
  pkgs,
  inputs,
  lib,
  ...
}:
with inputs.home-manager.lib.hm.gvariant;
let
  pop-shell-extension = import ./pop-shell.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    nautilus
    gnome-shell-extensions
    gnomeExtensions.appindicator
    pop-shell-extension
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.color-picker
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "appindicatorsupport@rgcjonas.gmail.com"
          "pop-shell@system76.com"
          "rounded-window-corners@fxgn"
          "color-picker@tuberry"
        ];
      };
      "org/gnome/gnome-session" = {
        auto-save-session = true;
      };
      "org/gnome/desktop/interface" = {
        #monospace-font-name = config.fontProfiles.monospace.name;
        #font-name = config.fontProfiles.regular.name;
        color-scheme = "prefer-dark";
        scaling-factor = lib.gvariant.mkUint32 2;
      };
      "org/gnome/desktop/background" = {
        primary-color = "#11111a";
        secondary-color = "#1e1e2e";
        picture-uri = "file://${../default_wallpaper.png}";
        picture-uri-dark = "file://${../default_wallpaper.png}";
        picture-options = "zoom";
      };
      "org/gnome/desktop/screensaver" = {
        primary-color = "#11111a";
        secondary-color = "#1e1e2e";
        screensaver = "file://${../default_wallpaper.png}";
        picture-options = "zoom";
        show-full-name-in-top-bar = false;
        status-message-enabled = false;
        lock-delay = 1200;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/calendar" = {
        show-weekdate = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        middle-click-emulation = true;
      };
      "org/gnome/desktop/input-sources" = {
        current = "uint32 0";
        sources = [
          "xkb"
          "pl"
        ];
        xkb-options = [ "terminate:ctrl_alt_bksp" ];
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
        workspaces-only-on-primary = false;
        dynamic-workspaces = false;
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 4;
        focus-mode = "click";
        theme = "Collopuccisharp-dark";
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = false;
        night-light-temperature = 3500;
        night-light-schedule-automatic = true;
        night-light-last-coordinates = mkTuple [
          51.7673
          18.0853
        ];
      };
      "org/gnome/eog/ui" = {
        image-gallery = true;
      };
      # Enable and configure pop-shell
      # (see https://github.com/pop-os/shell/blob/master_jammy/scripts/configure.sh)
      "org/gnome/shell/extensions/pop-shell" = {
        active-hint = true;
        active-hint-border-radius = 0;
        gap-inner = 2;
        gap-outer = 0;
        hint-color-rgba = "rgba(203, 166, 247, 1)";
      };
      "org/gnome/shell/extensions/user-theme" = {
        name = "Collopuccisharp-dark";
      };

      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small";
      };

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
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
        screensaver = "@as ['<Super>Escape']";
        rotate-video-lock-static = [ ];
        home = [ "<Super>e" ];
        email = [ ];
        www = [ ];
        terminal = [ ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>z";
        command = "gnome-terminal"; # TODO: use configured "default"
        name = "Open Terminal";
      };
    };
  };
}
