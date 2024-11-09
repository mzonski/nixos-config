{ pkgs, lib, ... }:

{
  imports = [
    ./gnome
    ./peazip
    ./templates

    ./catpuccin.nix
    ./firefox.nix
    ./flameshot.nix
    ./font.nix
    ./gtk.nix
    ./image-manipulation.nix
  ];

  home.packages = (
    with pkgs;
    [
      libnotify
      # arandr # xrandr gui config tool

      dconf-editor # dconf gui config tool
    ]
  );

  # xdg.portal.enable = true;
}
