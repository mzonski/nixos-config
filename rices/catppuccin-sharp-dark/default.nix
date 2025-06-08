{ pkgs, delib, ... }:
delib.rice {
  name = "catppuccin-sharp-dark";
  inherits = [ "homelab" ];

  wallpaper = ./assets/wallpaper.png;

  fonts = {
    monospace = {
      name = "FiraCode Nerd Font Mono";
      package = pkgs.nerd-fonts.fira-code;
      size = 12;
    };
    sans = {
      name = "Fira Sans Book";
      package = pkgs.fira;
      size = 14;
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
      size = 14;
    };
  };
}
