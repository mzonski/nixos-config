{
  pkgs,
  lib,
  lib',
  config,
  ...
}:

let
  enabled = config.programs.ristretto.enable;
  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
in
{
  options.programs.ristretto = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    home.packages = with pkgs; [
      xfce.ristretto # Decent image viewer
    ];

    xdg.mimeApps = {
      defaultApplications = {
        "image/jpeg" = [ "org.xfce.ristretto.desktop" ];
        "image/png" = [ "org.xfce.ristretto.desktop" ];
        "image/gif" = [ "org.xfce.ristretto.desktop" ];
        "image/svg+xml" = [ "org.xfce.ristretto.desktop" ];
      };
    };
  };

}
