{
  config,
  delib,
  pkgs,
  ...
}:
let
  inherit (delib) module;
in
module {
  name = "programs.wayland.hyprland";

  home.ifEnabled =
    { myconfig, ... }:
    let
      cmds = myconfig.commands;
      fontName = myconfig.rice.fonts.regular.name;
    in
    {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
          rofi-systemd
        ];
        font = fontName;
        terminal = cmds.runTerminal;
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
