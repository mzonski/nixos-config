{
  delib,
  pkgs,
  host,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.pcmanfm";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled = {
    home.packages = with pkgs; [
      lxqt.pcmanfm-qt
      xarchiver
    ];
  };
}
