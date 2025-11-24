{
  delib,
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

  gnomeExtensions =
    with pkgs;
    [
      systemdrebootmenuext
    ]
    ++ (with pkgs.gnomeExtensions; [
      appindicator
      color-picker
      caffeine
      dash-to-panel
      emoji-copy
      gtk4-desktop-icons-ng-ding
      lilypad
      cronomix
      clipboard-history
      #tophat
      #paperwm
      #rounded-window-corners-reborn
      #wintile-windows-10-window-tiling-for-gnome
      #workspaces-indicator-by-open-apps
    ])
    ++ [ pop-shell-extension ];
in
module {
  name = "programs.gnome";

  home.ifEnabled =
    { cfg, ... }:
    {
      home.packages = cfg.extensions ++ gnomeExtensions ++ (with pkgs; [ gnome-shell-extensions ]);

      dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = [
              "apps-menu@gnome-shell-extensions.gcampax.github.com"
              "drive-menu@gnome-shell-extensions.gcampax.github.com"
              "places-menu@gnome-shell-extensions.gcampax.github.com"
              "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
              "system-monitor@gnome-shell-extensions.gcampax.github.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
            ]
            ++ (map (ext: ext.extensionUuid) (gnomeExtensions ++ cfg.extensions));
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
