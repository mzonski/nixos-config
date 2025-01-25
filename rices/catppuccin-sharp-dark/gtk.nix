{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.hom.theme.catpuccin) enable;

  inherit (lib) mkIf;

  themeName = "Colloid-Purple-Dark-Compact-Catppuccin";
  iconThemeName = "Papirus-Dark";
in
{
  config = mkIf enable (
    let
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
    in
    {
      home.packages = [
        colloid-theme
        pkgs.apple-cursor
      ];

      gtk = {
        enable = true;
        iconTheme = {
          name = iconThemeName;
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "mauve";
            papirus-icon-theme = pkgs.papirus-icon-theme;
          };
        };
        cursorTheme = {
          package = pkgs.apple-cursor;
          name = "macOS";
          size = 24;
        };
        theme = {
          name = themeName;
          package = colloid-theme;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          monospace-font-name = config.hom.theme.fontProfiles.monospace.name;
          font-name = config.hom.theme.fontProfiles.regular.name;
          color-scheme = "prefer-dark";
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
    }
  );
}
