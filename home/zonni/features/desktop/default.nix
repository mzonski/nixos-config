{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./firefox.nix
    ./font.nix
    ./gtk.nix
  ];

  home.packages = [ pkgs.libnotify ];

  # Also sets org.freedesktop.appearance color-scheme
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  #xdg.portal.enable = true;
}
