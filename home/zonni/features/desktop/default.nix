{ pkgs, lib, ... }:

{
  imports = [
    ./catpuccin.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
  ];

  home.packages = (
    with pkgs;
    [
      libnotify
      # arandr # xrandr gui config tool

      dconf-editor # dconf gui config tool
    ]
  );

  # Also sets org.freedesktop.appearance color-scheme
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    scaling-factor = lib.gvariant.mkUint32 2;
  };

  # xdg.portal.enable = true;
}
