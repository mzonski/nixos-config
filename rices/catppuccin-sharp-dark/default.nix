{ pkgs, delib, ... }:
delib.rice {
  name = "catppuccin-sharp-dark";
  inherits = [ "homelab" ];

  wallpaper = ./assets/wallpaper.png;

  fonts = {
    monospace = {
      name = "FiraCode Nerd Font Mono";
      package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      size = 12;
    };
    regular = {
      name = "Fira Sans Book";
      package = pkgs.fira;
      size = 14;
    };
  };
}
