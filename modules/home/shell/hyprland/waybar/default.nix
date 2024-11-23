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
  enabled = config.hom.shell.hyprland.waybar.enable;
in
{
  options.hom.shell.hyprland.waybar = {
    enable = mkBoolOpt false;
  };

  config = mkIf enabled {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      });
    };
  };
}
