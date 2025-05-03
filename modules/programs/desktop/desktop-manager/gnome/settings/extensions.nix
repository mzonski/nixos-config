{
  delib,
  lib,
  pkgs,
  ...
}:
let
  inherit (delib) module;
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

  home.ifEnabled = {
    home.packages =
      with pkgs;
      [
        gnome-shell-extensions

      ]
      ++ (with pkgs.gnomeExtensions; [
        appindicator
        color-picker
        caffeine
        dash-to-panel
        emoji-copy
        gtk4-desktop-icons-ng-ding
        tophat
        lilypad
        cronomix
        clipboard-history
        #paperwm
        #rounded-window-corners-reborn
        #wintile-windows-10-window-tiling-for-gnome
        #workspaces-indicator-by-open-apps

      ])
      ++ [ pop-shell-extension ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "apps-menu@gnome-shell-extensions.gcampax.github.com"
            "caffeine@patapon.info"
            "clipboard-history@alexsaveau.dev"
            "color-picker@tuberry"
            "cronomix@zagortenay333"
            "dash-to-panel@jderose9.github.com"
            "drive-menu@gnome-shell-extensions.gcampax.github.com"
            "gtk4-ding@smedius.gitlab.com"
            "lilypad@shendrew.github.io"
            "places-menu@gnome-shell-extensions.gcampax.github.com"
            "pop-shell@system76.com"
            "system-monitor@gnome-shell-extensions.gcampax.github.com"
            "tophat@fflewddur.github.io"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
            #"dual-monitor-toggle@poka"
            #"emoji-copy@felipeftn"
            #"rounded-window-corners@fxgn"
          ];
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
      };
    };
  };
}
