{
  delib,
  ...
}:
let
  inherit (delib)
    module
    boolOption
    moduleOptions
    intOption
    strOption
    ;
in
module {
  name = "hardware.battery-threshold";

  options = moduleOptions {
    enable = boolOption false;
    threshold = intOption 80;
    batteryId = strOption "BAT0";
  };

  nixos.ifEnabled =
    { cfg, ... }:
    let
      threshold = builtins.toString cfg.threshold;
      thresholdFile = "/sys/class/power_supply/${cfg.batteryId}/charge_control_end_threshold";
    in
    {
      systemd.services.set-battery-charge-threshold = {
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";
        script = ''
          if [ -f "${thresholdFile}" ]; then
            echo "${threshold}" > "${thresholdFile}"
            echo "Battery charge threshold set to ${threshold}%"
          fi
        '';
      };
    };
}
