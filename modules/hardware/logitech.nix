{ delib, pkgs, ... }:
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

      boot.kernelParams = [
        "usbhid.quirks=0x046d:0xc548:0x00000400" # Logitech Bolt; HID_QUIRK_ALWAYS_POLL
        "usbcore.quirks=046d:c548:be" # Logitech Bolt; USB_QUIRK_RESET + USB_QUIRK_RESET_RESUME
      ];

      services.system76-scheduler.assignments."games".matchers = [
        "\"${pkgs.solaar}/bin/.solaar-wrapped\""
      ];
    };

  home.ifEnabled = {
    systemd.user.services.solaar = {
      Unit = {
        Description = "Solaar - Logitech Unifying Receiver configuration tool";
        After = [ "graphical-session.target" ];
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
