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
      services.system76-scheduler.assignments."games".matchers = [
        "\"${pkgs.solaar}/bin/.solaar-wrapped\""
      ];
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
