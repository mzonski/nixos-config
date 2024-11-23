{
  config,
  options,
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
      home.packages = [ colloid-theme ];
      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        theme = {
          name = "Colloid-Purple-Dark-Compact-Catppuccin";
          package = colloid-theme;
        };
      };

      services.xsettingsd = {
        enable = true;
      };

      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    }
  );
}
