{ ... }:

let
  luksUUID = "luks-6b1c8646-f768-4c08-b5ba-77462f4b4d4e";
  luksDevice = "/dev/disk/by-uuid/6b1c8646-f768-4c08-b5ba-77462f4b4d4e";
in
{
  boot.initrd.luks.devices."${luksUUID}".device = luksDevice;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
