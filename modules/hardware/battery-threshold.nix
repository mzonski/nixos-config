{
  delib,
  pkgs,
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
      services.udev.packages = [
        (pkgs.writeTextDir "etc/udev/rules.d/60-battery-charge-threshold.rules" ''
          SUBSYSTEM=="power_supply", KERNEL=="${cfg.batteryId}", RUN+="${pkgs.bash}/bin/sh -c 'echo ${threshold} > ${thresholdFile}'"
        '')
      ];
    };
}
