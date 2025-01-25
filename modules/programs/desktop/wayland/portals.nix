{
  config,
  lib,
  pkgs,
  ...
}:

let
  enabled = config.hom.wayland-wm.hyprland.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    services.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };
  };
}
