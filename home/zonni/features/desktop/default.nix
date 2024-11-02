{ pkgs, lib, ... }:

{
  imports = [
    ./catpuccin.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./gnome
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
