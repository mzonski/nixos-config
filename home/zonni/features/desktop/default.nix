{ pkgs, lib, ... }:

{
  imports = [
    ./gnome
    ./templates

    ./catpuccin.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./image-manipulation.nix
    ./peazip.nix
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
