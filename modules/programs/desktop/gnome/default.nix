{
  delib,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
  pop-shell-extension = pkgs.gnomeExtensions.pop-shell.overrideAttrs (oldAttrs: {
    postInstall = ''
      ${oldAttrs.postInstall or ""}
      # hint size and some colors
      for file in $out/share/gnome-shell/extensions/pop-shell@system76.com/{dark,light,highcontrast}.css; do
        cp -f ${./pop-shell-catpuccin.css} "$file"
      done

      # sets inactive tab background (why not covered by css, lol)
      ${pkgs.gnused}/bin/sed -i 's/#9B8E8A/#181825/g' "$out/share/gnome-shell/extensions/pop-shell@system76.com/stack.js"
    '';
  });
in
module {
  name = "programs.gnome";

  options = singleEnableOption host.isDesktop;

  # Put all displays in standby:
  # busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1
  # Resume all displays:
  # busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 0

  nixos.ifEnabled = {
    services.xserver = {
      enable = true;
      #displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      inherit (lib.gvariant) mkTuple;
      inherit (myconfig.rice) wallpaper fonts gtkThemeName;
    in
    {
      home.packages = with pkgs; [
        nautilus
        gnome-shell-extensions
        pop-shell-extension
        gnomeExtensions.appindicator
        gnomeExtensions.rounded-window-corners-reborn
        gnomeExtensions.color-picker
        gnomeExtensions.caffeine
        gnomeExtensions.emoji-copy
        gnomeExtensions.desktop-icons-ng-ding
        gnomeExtensions.dash-to-panel
      ];

      dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "dash-to-panel@jderose9.github.com"
              "apps-menu@gnome-shell-extensions.gcampax.github.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "system-monitor@gnome-shell-extensions.gcampax.github.com"
              "places-menu@gnome-shell-extensions.gcampax.github.com"
              "drive-menu@gnome-shell-extensions.gcampax.github.com"
              "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
              "appindicatorsupport@rgcjonas.gmail.com"
              "pop-shell@system76.com"
              "rounded-window-corners@fxgn"
              "color-picker@tuberry"
              "caffeine@patapon.info"
              "emoji-copy@felipeftn"
              "ding@rastersoft.com"
            ];
          };
          "org/gnome/gnome-session" = {
            auto-save-session = true;
          };
          "org/gnome/desktop/interface" = {
            monospace-font-name = fonts.monospace.name;
            font-name = fonts.regular.name;
            color-scheme = "prefer-dark";
            scaling-factor = lib.gvariant.mkUint32 2;
          };
          "org/gnome/desktop/background" = {
            primary-color = "#11111a";
            secondary-color = "#1e1e2e";
            picture-uri = "file://${wallpaper}";
            picture-uri-dark = "file://${wallpaper}";
            picture-options = "zoom";
          };
          "org/gnome/desktop/screensaver" = {
            primary-color = "#11111a";
            secondary-color = "#1e1e2e";
            screensaver = "file://${wallpaper}";
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
            theme = gtkThemeName;
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
            active-hint-border-radius = 1;
            gap-inner = 2;
            gap-outer = 0;
            hint-color-rgba = "rgba(203, 166, 247, 1)";
          };
          "org/gnome/shell/extensions/user-theme" = {
            name = "Colloid-Purple-Dark-Compact-Catppuccin";
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
            command = "kitty"; # TODO: use configured "default"
            name = "Open Terminal";
          };
        };
      };
    };
}
