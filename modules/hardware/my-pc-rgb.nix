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
  name = "hardware.my-pc-rgb";

  options = singleEnableOption false;

  nixos.ifEnabled =
    { cfg, ... }:
    {

      systemd.services.my-pc-rgb = {
        description = "RGB lighting";

        wantedBy = [
          "multi-user.target"
          #"sleep.target"
        ];
        after = [
          "multi-user.target"
          #"sleep.target"
          #"systemd-udev-settle.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${inputs.nixos-extra.packages.my-pc-rgb}/bin/my-pc-rgb";
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
        '')
      ];
    };
}
