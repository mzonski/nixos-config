{
  config,
  pkgs,
  mylib,
  ...
}:

with mylib;
let
  enabled = config.hom.wayland-wm.panel.waybar.enable;
in
{
  config = mkIf enabled {
    home.packages = with pkgs; [
      libnotify
      hyprContrib.grimblast
    ];
  };
}
