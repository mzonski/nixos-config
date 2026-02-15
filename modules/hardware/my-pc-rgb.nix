{
  delib,
  inputs,
  pkgs,
  system,
  ...
}:
let
  inherit (delib) module singleEnableOption;
in
module {
  name = "hardware.my-pc-rgb";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { cfg, ... }:
    {
      systemd.services.my-pc-rgb = {
        description = "My PC RGB Background Service";
        wantedBy = [ "multi-user.target" ];
        conflicts = [
          "suspend.target"
          "poweroff.target"
          "reboot.target"
          "shutdown.target"
        ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${inputs.my-pc-rgb.packages.${system}.default}/bin/my-pc-rgb";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };

      systemd.services.my-pc-rgb-resume = {
        description = "Restart My PC RGB service";
        after = [ "suspend.target" ];
        wantedBy = [ "suspend.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart my-pc-rgb";
        };
      };

      services.udev.packages = [
        (pkgs.writeTextDir "etc/udev/rules.d/45-my-pc-rgb-devices.rules" ''
          # ASUS AURA LED Controller
          SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19af", TAG+="uaccess"

          # Corsair Lighting Node Core
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0c1a", TAG+="uaccess"
        '')
      ];
    };
}
