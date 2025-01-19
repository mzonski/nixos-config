{
  config,
  pkgs,
  lib,
  ...
}:

let
  enabled = config.hom.wayland-wm.panel.waybar.enable;

  inherit (lib) mkIf;
in
{
  config = mkIf enabled {
    home.packages = with pkgs; [
      libnotify
      unstable.grimblast
    ];
  };
}
