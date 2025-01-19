{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

with lib;
with lib';
let
  enabled = config.hom.wayland-wm.hyprland.enable;
in
{
  config = mkIf enabled {
    # Polkit
    services.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        pkgs.unstable.xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        xdg-desktop-portal-kde
        xdg-desktop-portal-wlr
      ];
      config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        };
      };
    };
  };
}
