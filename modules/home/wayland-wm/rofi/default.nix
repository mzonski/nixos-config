{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with mylib;
with lib;
let
  enabled = config.hom.wayland-wm.hyprland.enable;
  fontProfile = config.hom.theme.fontProfiles.regular;
in
{
  config = mkIf enabled {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
        rofi-systemd
      ];
      font = fontProfile.name;
      #terminal = "${pkgs.kitty}/bin/kitty";
    };
  };

}
