{ delib, ... }:
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
    services.desktopManager.plasma6.enable = true;
    services.desktopManager.plasma6.enableQt5Integration = true;

    services.dbus.implementation = "dbus";

    systemd.services.display-manager = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
