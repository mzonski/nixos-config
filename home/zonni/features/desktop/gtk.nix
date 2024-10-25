{ pkgs, ... }:
{
  gtk = {
    enable = true;
  };

  services.xsettingsd = {
    enable = true;
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
