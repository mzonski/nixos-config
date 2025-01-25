{
  config,
  lib,
  pkgs,
  lib',
  ...
}:

let
  enabled = config.hom.wayland-wm.panel.waybar.enable;

  inherit (lib') mkBoolOpt;
  inherit (lib) mkIf;
in
{
  options.hom.wayland-wm.panel.waybar = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "graphical-session.target";
      package = pkgs.unstable.waybar;
      # package = pkgs.waybar.overrideAttrs (oa: {
      #   mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      # });
    };
  };
}
