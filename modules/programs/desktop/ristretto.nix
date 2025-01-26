{
  delib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.ristretto";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = {
    home.packages = with pkgs; [
      xfce.ristretto # Decent image viewer
    ];

    xdg.mimeApps.defaultApplications = {
      "image/jpeg" = [ "org.xfce.ristretto.desktop" ];
      "image/png" = [ "org.xfce.ristretto.desktop" ];
      "image/gif" = [ "org.xfce.ristretto.desktop" ];
      "image/svg+xml" = [ "org.xfce.ristretto.desktop" ];
    };
  };
}
