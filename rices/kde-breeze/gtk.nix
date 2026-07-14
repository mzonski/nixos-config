{ pkgs, delib, ... }:
let
  cursorTheme = {
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
  };
in
delib.rice {
  name = "kde-breeze";

  cursor = cursorTheme;

  packages = [
    pkgs.apple-cursor
  ];

  home =
    { cfg, ... }:
    {
      gtk = {
        enable = true;
        inherit cursorTheme;
        iconTheme = {
          name = "breeze-dark";
          package = pkgs.kdePackages.breeze-icons;
        };
        theme = {
          name = "Breeze-Dark";
        };

        gtk2.extraConfig = ''
          gtk-enable-animations=1
          gtk-primary-button-warps-slider=1
          gtk-toolbar-style=3
          gtk-menu-images=1
          gtk-button-images=1
          gtk-cursor-blink-time=1000
          gtk-cursor-blink=1
          gtk-sound-theme-name="ocean"
        '';
      };

      services.xsettingsd = {
        enable = false;
        settings = {
          "Net/ThemeName" = "Breeze-Dark";
          "Net/IconThemeName" = "breeze-dark";
        };
      };
    };
}
