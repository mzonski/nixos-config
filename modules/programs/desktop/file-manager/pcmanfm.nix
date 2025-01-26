{ delib, pkgs, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.pcmanfm";

  options = singleEnableOption false;

  home.ifEnabled = {
    home.packages = with pkgs; [
      lxqt.pcmanfm-qt
      xarchiver
    ];
  };
}
