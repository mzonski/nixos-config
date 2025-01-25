{ delib, ... }:

let
  inherit (delib) module singleEnableOption;
in
module {
  name = "hardware.bluetooth";

  options = singleEnableOption false;

  nixos.ifEnabled = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    services.blueman.enable = true;
  };
}
