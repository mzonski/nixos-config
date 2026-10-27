{ pkgs, delib, ... }:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.desktop.gitkraken";

  options = singleEnableOption false;

  home.ifEnabled.home.packages = with pkgs; [
    gitkraken
  ];
}
