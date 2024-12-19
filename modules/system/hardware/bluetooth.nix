{
  options,
  config,
  lib,
  pkgs,
  mylib,
  ...
}:

with lib;
with mylib;
let
  enabled = config.hardware.bluetooth.enable;

in
{
  config = mkIf enabled {

    # environment.systemPackages = with pkgs; [
    #   bluez
    # ];

    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        # Experimental = true; show charge percent
      };
    };
  };
}
