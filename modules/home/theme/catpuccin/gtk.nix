{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  inherit (config.hom.theme.catpuccin) enable;
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
      home.packages =
        [
          colloid-theme
        ]
        ++ (with pkgs; [
          apple-cursor
        ]);
      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus-Dark";
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
          name = "Colloid-Purple-Dark-Compact-Catppuccin";
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
          "Net/ThemeName" = "${gtk.theme.name}";
          "Net/IconThemeName" = "${gtk.iconTheme.name}";
        };
      };

      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    }
  );
}
