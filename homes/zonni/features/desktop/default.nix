{ pkgs, lib, ... }:

{
  imports = [
    #./gnome
    ./hyprland
    ./peazip
    ./templates

    ./bleachbit.nix
    ./catpuccin.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./image-manipulation.nix
    ./openvpn.nix
    ./qcad.nix
    ./qdirstat.nix
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
