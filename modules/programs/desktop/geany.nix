{
  pkgs,
  delib,
  host,
  ...
}:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.geany";

  options = singleEnableOption false;

  home.ifEnabled.home.packages = with pkgs; [
    geany # text editor
  ];
}
