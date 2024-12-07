{
  inputs,
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
  enabled = config.hom.wayland-wm.panel.waybar.enable;
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
      package = pkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      });

    };
  };
}
