{
  config,
  pkgs,
  lib,
  lib',
  ...
}:

with lib;
with lib';
let
  enabled = config.hom.wayland-wm.panel.waybar.enable;
in
{
  config = mkIf enabled {
    home.packages = with pkgs; [
      libnotify
      unstable.grimblast
    ];
  };
}
