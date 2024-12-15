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
  enabled = config.hom.wayland-wm.hyprland.enable;
in
{
  config = mkIf enabled {
    # Polkit
    services.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        xdg-desktop-portal-kde
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

    # xdg.portal = {
    #   enable = true;
    #   extraPortals = with pkgs; [
    #     xdg-desktop-portal-gtk
    #     xdg-desktop-portal-kde
    #     xdg-desktop-portal-wlr
    #   ];
    #   config = {
    #     common = {
    #       default = [
    #         "xdph"
    #         "gtk"
    #       ];
    #       "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    #       "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-kde" ];
    #     };
    #     hyprland = {
    #       default = [
    #         "wlr"
    #         "gtk"
    #       ];
    #     };
    #   };
    # };
  };
}
