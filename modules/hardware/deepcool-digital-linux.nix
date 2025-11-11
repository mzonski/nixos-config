{
  delib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "hardware.deepcool-digital-linux";

  options = singleEnableOption false;

  nixos.always.imports = [
    inputs.deepcool-digital-linux.nixosModules.default
  ];

  nixos.ifEnabled =
    { cfg, ... }:
    {
      hardware.deepcool-digital-linux = {
        enable = true;
        systemd = {
          enable = true;
          mode = "cpu_freq";
          updateMs = 2000;
        };
      };

      services.udev.packages = [
        (pkgs.writeTextDir "etc/udev/rules.d/42-deepcool-digital-linux-custom.rules" ''
          # Intel RAPL energy usage file
          ACTION=="add", SUBSYSTEM=="powercap", KERNEL=="intel-rapl:0", RUN+="${pkgs.coreutils}/bin/chmod 444 /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj"

          # DeepCool HID raw devices
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3633", MODE="0666"
        '')
      ];
    };
}
