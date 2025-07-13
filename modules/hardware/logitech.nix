{ delib, lib, ... }:
let
  inherit (delib) module boolOption;
  inherit (lib) mkIf;
in
module {
  name = "hardware.logitech";

  options.hardware.logitech = {
    enable = boolOption false;
    disablePowerWakeupEvents = boolOption true;
  };

  nixos.ifEnabled =
    { cfg, ... }:
    {
      hardware.logitech.wireless.enableGraphical = true;
      hardware.logitech.wireless.enable = true;

      services.udev.extraRules = mkIf cfg.disablePowerWakeupEvents (''
        # Disable power wakeup events for Logitech, Inc. Logi Bolt Receiver
        ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled"
      '');
    };
}
