{ config, lib, ... }:

let
  inherit (lib) mkIf;
  enabled = config.hardware.bluetooth.enable;

in
{
  config = mkIf enabled {
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
