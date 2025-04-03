{
  delib,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "programs.kde";

  options = singleEnableOption false;

  myconfig.ifEnabled = {
    programs.sddm.enable = true;
  };

  nixos.ifEnabled = {
    #services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.desktopManager.plasma6.enableQt5Integration = true;
  };
}
