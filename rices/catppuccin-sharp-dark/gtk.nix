{
  pkgs,
  delib,
  ...
}:
let
  themeName = "Colloid-Purple-Dark-Compact-Catppuccin";
  iconThemeName = "Papirus-Dark";
  iconPackage = pkgs.papirus-icon-theme;

  colloid-theme =
    (pkgs.colloid-gtk-theme.override {
      themeVariants = [ "purple" ];
      colorVariants = [ "dark" ];
      sizeVariants = [ "compact" ];
      tweaks = [
        "catppuccin"
        "rimless"
        "normal"
        "black"
      ];
    }).overrideAttrs
      (oldAttrs: {
        preInstall = ''
          ${oldAttrs.preInstall or ""}
          cp -f ${./assets/_colloid-theme-variables.scss} src/sass/_variables.scss
        '';
      });

  cursorTheme = {
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
  };
in
delib.rice {
  name = "catppuccin-sharp-dark";

  cursor = cursorTheme;
  gtkThemeName = themeName;
  icons = {
    name = iconThemeName;
    package = iconPackage;
  };

  packages = [
    colloid-theme
    pkgs.apple-cursor
  ];

  home =
    { cfg, ... }:
    {
      gtk = {
        enable = true;
        inherit cursorTheme;
        iconTheme = {
          name = iconThemeName;
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "mauve";
            papirus-icon-theme = pkgs.papirus-icon-theme;
          };
        };
        theme = {
          name = themeName;
          package = colloid-theme;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          monospace-font-name = cfg.fonts.monospace.name;
          font-name = cfg.fonts.regular.name;
          color-scheme = "prefer-dark";
          accent-color = "purple";
        };
      };

      services.xsettingsd = {
        enable = false; # on wayland we don't need x11, think what if you need to use x11
        settings = {
          "Net/ThemeName" = themeName;
          "Net/IconThemeName" = iconThemeName;
        };
      };

      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
}
