{
  pkgs,
  lib,
  lib',
  config,
  ...
}:
with lib';
with lib;
let
  enabled = config.hom.wayland-wm.hyprland.enable;
  fontProfile = config.hom.theme.fontProfiles.regular;
  commands = config.commands;
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
      terminal = commands.runTerminal;
      cycle = false;
      extraConfig = {
        modi = "drun,window";
        drun-show-actions = true;

        click-to-exit = true;
        global-kb = true;

        window-thumbnail = true;
        sidebar-mode = false;
        disable-history = false;
        icon-theme = config.gtk.iconTheme.name;
      };
    };
  };
}
