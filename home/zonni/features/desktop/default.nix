{ pkgs, lib, ... }:

{
  imports = [
    ./gnome
    ./peazip
    ./templates

    ./bleachbit.nix
    ./catpuccin.nix
    ./clipboard-manager.nix
    ./firefox.nix
    ./flameshot.nix
    ./font.nix
    ./gtk.nix
    ./image-manipulation.nix
    ./openvpn.nix
    ./qcad.nix
    ./vlc.nix
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
