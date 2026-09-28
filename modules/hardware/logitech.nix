{
  delib,
  pkgs,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "hardware.logitech";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { cfg, ... }:
    {
      hardware.logitech.wireless.enableGraphical = true;
      hardware.logitech.wireless.enable = true;
      services.system76-scheduler.assignments."games".matchers = [
        "\"${pkgs.solaar}/bin/.solaar-wrapped\""
        "\"${pkgs.solaar}/bin/solaar-cli\""
        "\"${pkgs.solaar}/bin/solaar\""
      ];

      services.udev.extraRules = ''
        # Disable power wakeup events for Logitech, Inc. Logi Bolt Receiver
        ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled"
      '';
    };

  home.ifEnabled = {
    systemd.user.services.solaar = {
      Unit = {
        Description = "Solaar - Logitech Unifying Receiver configuration tool";
        After = "display-manager.service";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.solaar}/bin/solaar --window=hide";
        Restart = "on-failure";
      };
    };
  };
}
