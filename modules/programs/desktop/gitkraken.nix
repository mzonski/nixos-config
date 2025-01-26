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
  name = "programs.desktop.gitkraken";

  options = singleEnableOption host.isDesktop;

  home.ifEnabled.home.packages = with pkgs; [
    unstable.gitkraken
  ];
}
