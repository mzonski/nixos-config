{ pkgs, ... }:
let
  collopuccisharp-theme = pkgs.callPackage ./theme/collopuccisharp-gtk-theme.nix ({
    # themeVariants = [ "purple" ];
    # colorVariants = [ "dark" ];
    # sizeVariants = [ "compact" ];
    # tweaks = [
    #   "catppuccin"
    #   "rimless"
    #   "normal"
    #   "black"
    # ];
  });
in
{

  home.packages = [ collopuccisharp-theme ];
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Collopuccisharp-dark";
      package = collopuccisharp-theme;
    };
  };

  services.xsettingsd = {
    enable = true;
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
