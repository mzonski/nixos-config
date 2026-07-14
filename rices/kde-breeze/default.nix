{ pkgs, delib, ... }:
delib.rice {
  name = "kde-breeze";
  inherits = [ "homelab" ];

  fonts = {
    monospace = {
      name = "FiraCode Nerd Font Mono";
      package = pkgs.nerd-fonts.fira-code;
      size = 12;
    };
    sans = {
      name = "Fira Sans Book";
      package = pkgs.fira;
      size = 10;
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
      size = 14;
    };
  };
}
